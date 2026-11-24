#!/usr/bin/env node
/**
 * Decision evals for SA-MP/open.mp agents.
 *
 * Each scenario asks one question an agent must answer correctly (target
 * verdict, security rule, severity). Two modes:
 *
 *   node bin/samp-agent-evals.js                     # run the deterministic toolchain
 *   node bin/samp-agent-evals.js --answers a.json    # grade captured agent answers
 *   node bin/samp-agent-evals.js --template          # prompt skeleton for an agent
 *
 * The harness never calls an LLM: it grades decisions. Toolchain mode proves the
 * decision layer works; answers mode measures whether an agent reached those
 * decisions on its own.
 */
'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const SCENARIOS = path.join(ROOT, '.agents/skills/samp-agent-evals/scenarios');
const DETECT = path.join(__dirname, 'samp-detect.js');
const LINT = path.join(__dirname, 'samp-lint.js');

function parseArgs(argv) {
  const args = { json: false, answers: '', template: false, min: 1 };
  for (const arg of argv) {
    if (arg === '--json') args.json = true;
    else if (arg === '--template') args.template = true;
    else if (arg === '--answers') args.answers = '__missing__';
    else if (args.answers === '__missing__') {
      if (!arg.startsWith('--')) args.answers = arg;
    } else if (arg.startsWith('--min=')) {
      args.min = Number(arg.slice('--min='.length));
      if (Number.isNaN(args.min) || args.min < 0 || args.min > 1) {
        console.error('samp-agent-evals: --min must be between 0 and 1');
        process.exit(2);
      }
    } else if (arg.startsWith('--')) {
      console.error(`samp-agent-evals: unknown argument '${arg}'`);
      process.exit(2);
    }
  }
  if (args.answers === '__missing__') {
    console.error('samp-agent-evals: --answers needs a file path');
    process.exit(2);
  }
  return args;
}

function runJson(script, runArgs) {
  const result = spawnSync(process.execPath, [script, ...runArgs, '--json'], { encoding: 'utf8' });
  if (result.status !== 0 && !result.stdout) {
    throw new Error(`${path.basename(script)} failed: ${result.stderr.trim()}`);
  }
  return JSON.parse(result.stdout);
}

function caseFile(dir) {
  for (const name of ['case.pwn', 'config.json', 'server.cfg']) {
    const full = path.join(dir, name);
    if (fs.existsSync(full)) return full;
  }
  return null;
}

function loadScenarios() {
  return fs
    .readdirSync(SCENARIOS, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => {
      const dir = path.join(SCENARIOS, entry.name);
      const metaPath = path.join(dir, 'meta.json');
      if (!fs.existsSync(metaPath)) return null;
      const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
      const file = caseFile(dir);
      if (!file) throw new Error(`scenario ${entry.name} has no case file`);
      return { id: entry.name, dir, file, meta };
    })
    .filter(Boolean)
    .sort((a, b) => a.id.localeCompare(b.id));
}

function observe(scenario) {
  const actual = {};

  if (scenario.file.endsWith('.pwn')) {
    const detection = runJson(DETECT, [scenario.file]);
    const scan = detection.files[0];
    actual.verdict = scan.verdict;
    actual.errorFindings = scan.findings.filter((finding) => finding.severity === 'error').length;
  }

  if (scenario.file.endsWith('.pwn') || scenario.file.endsWith('.json') || scenario.file.endsWith('.cfg')) {
    const lint = runJson(LINT, [scenario.file, '--include-corpus']);
    actual.rules = [...new Set(lint.findings.map((finding) => finding.rule))].sort();
  }
  return actual;
}

function compare(expected, actual) {
  const differences = [];
  for (const key of ['verdict', 'errorFindings']) {
    if (expected[key] === undefined) continue;
    if (actual[key] !== expected[key]) {
      differences.push(`${key}: expected ${JSON.stringify(expected[key])}, got ${JSON.stringify(actual[key])}`);
    }
  }
  if (expected.rules !== undefined) {
    const want = [...expected.rules].sort();
    const got = [...(actual.rules || [])].sort();
    if (JSON.stringify(want) !== JSON.stringify(got)) {
      differences.push(`rules: expected ${JSON.stringify(want)}, got ${JSON.stringify(got)}`);
    }
  }
  return differences;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const scenarios = loadScenarios();
  if (scenarios.length === 0) {
    console.error(`samp-agent-evals: no scenarios under ${SCENARIOS}`);
    process.exit(2);
  }

  if (args.template) {
    const template = {};
    for (const scenario of scenarios) {
      template[scenario.id] = { verdict: '', errorFindings: 0, rules: [] };
    }
    console.log(JSON.stringify({ instructions: 'Isi verdict (LEGACY|MODERN|COMPAT|DUAL|MIXED|UNKNOWN), jumlah errorFindings, dan daftar rules.', asks: Object.fromEntries(scenarios.map((s) => [s.id, s.meta.ask])), answers: template }, null, 2));
    return;
  }

  let answers = null;
  if (args.answers) {
    if (!fs.existsSync(args.answers)) {
      console.error(`samp-agent-evals: answers file not found: ${args.answers}`);
      process.exit(2);
    }
    answers = JSON.parse(fs.readFileSync(args.answers, 'utf8')).answers || JSON.parse(fs.readFileSync(args.answers, 'utf8'));
  }

  const results = [];
  for (const scenario of scenarios) {
    let actual;
    try {
      actual = answers ? (answers[scenario.id] || {}) : observe(scenario);
    } catch (error) {
      results.push({ id: scenario.id, passed: false, differences: [`harness error: ${error.message}`], actual: {}, expected: scenario.meta });
      continue;
    }
    const differences = compare(scenario.meta, actual);
    results.push({ id: scenario.id, passed: differences.length === 0, differences, actual, expected: scenario.meta });
  }

  const passed = results.filter((result) => result.passed).length;
  const rate = passed / results.length;

  if (args.json) {
    console.log(JSON.stringify({ mode: answers ? 'answers' : 'toolchain', passed, total: results.length, passRate: Number(rate.toFixed(3)), results }, null, 2));
  } else {
    for (const result of results) {
      console.log(`${result.passed ? 'PASS' : 'FAIL'}  ${result.id}`);
      for (const difference of result.differences) console.log(`      ${difference}`);
    }
    console.log(`\nmode=${answers ? 'answers' : 'toolchain'} pass=${passed}/${results.length} (${(rate * 100).toFixed(1)}%), min=${(args.min * 100).toFixed(0)}%`);
  }

  if (rate < args.min) process.exit(1);
}

main();
