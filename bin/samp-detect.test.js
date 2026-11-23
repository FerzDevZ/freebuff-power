#!/usr/bin/env node
/**
 * Contract tests for bin/samp-detect.js and the ownership matrix it consumes.
 * Real fixtures live in the encyclopedia skill and are compiled separately by
 * bin/self-test.sh; this file checks the verdicts and the failure modes.
 */
'use strict';

const assert = require('assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const DETECT = path.join(__dirname, 'samp-detect.js');
const FIXTURES = path.join(ROOT, '.agents/skills/samp-vs-openmp-encyclopedia/fixtures');
const OWNERSHIP = path.join(__dirname, 'data/native-ownership.json');

let checks = 0;

function check(label, fn) {
  checks++;
  try {
    fn();
  } catch (error) {
    console.error(`FAIL: ${label}\n  ${error.message}`);
    process.exitCode = 1;
  }
}

function detect(target, extraArgs = []) {
  const result = spawnSync(process.execPath, [DETECT, target, '--json', ...extraArgs], { encoding: 'utf8' });
  return { status: result.status, json: result.stdout ? JSON.parse(result.stdout) : null, stderr: result.stderr };
}

check('legacy fixture is LEGACY with high confidence', () => {
  const { json } = detect(path.join(FIXTURES, 'legacy_min.pwn'));
  assert.strictEqual(json.files[0].verdict, 'LEGACY');
  assert.strictEqual(json.files[0].confidence, 'high');
  assert.deepStrictEqual(json.files[0].findings.filter((f) => f.severity === 'error'), []);
});

check('modern fixture is MODERN and uses an open.mp-only native', () => {
  const { json } = detect(path.join(FIXTURES, 'modern_min.pwn'));
  assert.strictEqual(json.files[0].verdict, 'MODERN');
  assert.ok(json.files[0].modernOnly.includes('GetVehicleDriver'));
});

check('SAMP_COMPAT fixture is COMPAT, not MIXED', () => {
  const { json } = detect(path.join(FIXTURES, 'compat_min.pwn'));
  assert.strictEqual(json.files[0].verdict, 'COMPAT');
});

check('modern native inside a legacy file is an error and fails --strict', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'samp-detect-'));
  const file = path.join(dir, 'broken.pwn');
  fs.writeFileSync(file, '#include <a_samp>\nnew v = GetVehicleDriver(0);\n');

  const normal = detect(file);
  assert.strictEqual(normal.json.files[0].verdict, 'LEGACY');
  const errors = normal.json.files[0].findings.filter((f) => f.severity === 'error');
  assert.strictEqual(errors.length, 1);
  assert.match(errors[0].message, /GetVehicleDriver\(\) hanya ada di open\.mp/);
  assert.strictEqual(normal.status, 0);

  const strict = detect(file, ['--strict']);
  assert.strictEqual(strict.status, 1);
});

check('removed native in a modern file is a warning (deprecated shim exists)', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'samp-detect-'));
  const file = path.join(dir, 'shim.pwn');
  fs.writeFileSync(file, '#include <open.mp>\nnew size = GetPlayerPoolSize();\n');

  const { json } = detect(file);
  assert.strictEqual(json.files[0].verdict, 'MODERN');
  const warnings = json.files[0].findings.filter((f) => f.severity === 'warning');
  assert.strictEqual(warnings.length, 1);
  assert.match(warnings[0].message, /stock shim deprecated/);
});

check('one include per #if branch is DUAL, not MIXED', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'samp-detect-'));
  const file = path.join(dir, 'dual.pwn');
  fs.writeFileSync(file, '#if defined OMP_BUILD\n    #include <open.mp>\n#else\n    #include <a_samp>\n#endif\n\npublic OnGameModeInit() { return 1; }\n');

  const { json } = detect(file);
  assert.strictEqual(json.files[0].verdict, 'DUAL');
  assert.strictEqual(json.files[0].findings.filter((f) => f.severity === 'error').length, 0);
});

check('a library without includes is UNKNOWN, not guessed', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'samp-detect-'));
  const file = path.join(dir, 'lib.inc');
  fs.writeFileSync(file, 'stock Helper()\n{\n    return 1;\n}\n');

  const { json } = detect(file);
  assert.strictEqual(json.files[0].verdict, 'UNKNOWN');
  assert.strictEqual(json.files[0].findings[0].severity, 'info');
});

check('server.cfg + config.json are reported as a half-finished migration', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'samp-project-'));
  fs.writeFileSync(path.join(dir, 'server.cfg'), 'echo test\n');
  fs.writeFileSync(path.join(dir, 'config.json'), '{"pawn":{"main_scripts":["gm"]}}');
  fs.writeFileSync(path.join(dir, 'gm.pwn'), '#include <open.mp>\n');

  const { json } = detect(dir);
  assert.match(json.project.kind, /^HYBRID/);
});

check('ownership matrix keeps verified ownership apart from unknowns', () => {
  const matrix = JSON.parse(fs.readFileSync(OWNERSHIP, 'utf8'));
  const modernOnly = new Set(matrix.modernOnly.map((entry) => entry.name));
  const legacyOnly = new Map(matrix.legacyOnly.map((entry) => [entry.name, entry]));

  assert.ok(matrix.counts.modern > matrix.counts.legacy);
  assert.ok(modernOnly.has('GetVehicleDriver'));
  assert.ok(modernOnly.has('IsPlayerUsingOfficialClient'));
  assert.ok(!modernOnly.has('floatround'), 'floatround must not be claimed by open.mp');
  assert.ok(matrix.unverified.some((entry) => entry.name === 'floatround'));
  assert.strictEqual(legacyOnly.get('GetPlayerPoolSize').shim, true);
});

if (process.exitCode) {
  console.error(`samp-detect tests: ${checks} checks, FAILED`);
} else {
  console.log(`samp-detect tests: ${checks} checks, 0 failed`);
}
