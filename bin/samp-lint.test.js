#!/usr/bin/env node
/**
 * Contract tests for bin/samp-lint.js: every corpus file must produce exactly
 * the declared rules. A clean sample that starts firing is a broken rule, not a
 * finding, so this fails the build.
 */
'use strict';

const assert = require('assert');
const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const LINT = path.join(__dirname, 'samp-lint.js');
const CORPUS = path.join(ROOT, '.agents/skills/samp-security-lint/corpus');
const EXPECTATIONS = JSON.parse(fs.readFileSync(path.join(CORPUS, 'expectations.json'), 'utf8'));

let checks = 0;

function lint(target, extra = []) {
  const result = spawnSync(process.execPath, [LINT, target, '--json', ...extra], { encoding: 'utf8' });
  return {
    status: result.status,
    json: result.stdout ? JSON.parse(result.stdout) : null,
    stderr: result.stderr,
  };
}

function check(label, fn) {
  checks++;
  try {
    fn();
  } catch (error) {
    console.error(`FAIL: ${label}\n  ${error.message}`);
    process.exitCode = 1;
  }
}

for (const [relative, expected] of Object.entries(EXPECTATIONS)) {
  check(`corpus ${relative}`, () => {
    const { json } = lint(path.join(CORPUS, relative), ['--include-corpus']);
    const actual = [...new Set(json.findings.map((finding) => finding.rule))].sort();
    assert.deepStrictEqual(actual, [...expected].sort());
  });
}

check('a clean sample never counts as an error finding', () => {
  const { status, json } = lint(path.join(CORPUS, 'clean/format_safe.pwn'), ['--include-corpus', '--fail-on=error']);
  assert.strictEqual(json.findings.filter((f) => f.severity === 'error').length, 0);
  assert.strictEqual(status, 0);
});

check('a vulnerable sample fails --fail-on=error', () => {
  const { status } = lint(path.join(CORPUS, 'vulnerable/format_injection.pwn'), ['--include-corpus', '--fail-on=error']);
  assert.strictEqual(status, 1);
});

check('the repo skills scan has no error findings', () => {
  const { json, status } = lint(path.join(ROOT, '.agents/skills'), ['--fail-on=error']);
  const errors = json.findings.filter((f) => f.severity === 'error');
  assert.deepStrictEqual(errors, [], errors.map((e) => `${e.file}:${e.line} ${e.rule}`).join('\n'));
  assert.strictEqual(status, 0);
});

check('corpus is excluded from a normal scan', () => {
  const { json } = lint(path.join(ROOT, '.agents/skills/samp-security-lint'));
  assert.strictEqual(json.findings.length, 0, `unexpected findings: ${JSON.stringify(json.findings)}`);
});

if (process.exitCode) {
  console.error(`samp-lint tests: ${checks} checks, FAILED`);
} else {
  console.log(`samp-lint tests: ${checks} checks, 0 failed`);
}
