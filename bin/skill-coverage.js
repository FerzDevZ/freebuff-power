#!/usr/bin/env node
/**
 * Fixture-coverage gate for the SA-MP/open.mp skills.
 *
 *   node bin/skill-coverage.js            # verify against the committed baseline
 *   node bin/skill-coverage.js --update   # record the current state
 *
 * A skill "has a fixture" when it ships at least one .pwn; it is
 * "runtime-verified" when one of those carries the `// @runtime-suite` marker
 * that bin/self-test.sh executes. Regression means a skill that used to have a
 * fixture/verdict lost it — prose is allowed, silently losing proof is not.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKILLS = path.join(ROOT, '.agents/skills');
const BASELINE = path.join(__dirname, 'data/skill-coverage.json');
const PREFIXES = ['samp-', 'openmp-'];

const update = process.argv.includes('--update');
const unknown = process.argv.slice(2).filter((arg) => arg !== '--update');
if (unknown.length > 0) {
  console.error(`skill-coverage: unknown argument '${unknown[0]}'`);
  process.exit(2);
}

function pawnFiles(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    /* corpus/ holds intentionally broken inputs and scenarios/ eval inputs;
     * neither is a compile/run fixture owned by the skill. */
    if (entry.isDirectory() && (entry.name === 'corpus' || entry.name === 'scenarios')) continue;
    if (entry.isDirectory()) out.push(...pawnFiles(full));
    else if (entry.name.endsWith('.pwn')) out.push(full);
  }
  return out;
}

const skills = fs
  .readdirSync(SKILLS, { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && PREFIXES.some((prefix) => entry.name.startsWith(prefix)))
  .map((entry) => entry.name)
  .sort();

const state = { total: skills.length, fixtures: [], runtime: [], proseOnly: [] };

for (const skill of skills) {
  const files = pawnFiles(path.join(SKILLS, skill));
  if (files.length === 0) {
    state.proseOnly.push(skill);
    continue;
  }
  state.fixtures.push(skill);
  const verified = files.some((file) => fs.readFileSync(file, 'utf8').includes('// @runtime-suite'));
  if (verified) state.runtime.push(skill);
}

if (update) {
  const baseline = {
    note: 'Baseline cakupan fixture skill SA-MP/open.mp. Regenerate: node bin/skill-coverage.js --update',
    total: state.total,
    fixtures: state.fixtures,
    runtime: state.runtime,
  };
  fs.mkdirSync(path.dirname(BASELINE), { recursive: true });
  fs.writeFileSync(BASELINE, `${JSON.stringify(baseline, null, 2)}\n`);
  console.log(`baseline ditulis: ${BASELINE}`);
}

const summary =
  `cakupan: ${state.total} skill — fixture ${state.fixtures.length}, ` +
  `runtime ${state.runtime.length}, prosa ${state.proseOnly.length}`;

if (!fs.existsSync(BASELINE)) {
  console.error(`${summary}\nskill-coverage: baseline belum ada — jalankan node bin/skill-coverage.js --update`);
  process.exit(2);
}

const baseline = JSON.parse(fs.readFileSync(BASELINE, 'utf8'));
const regressions = [];

for (const skill of baseline.fixtures || []) {
  if (!state.fixtures.includes(skill)) regressions.push(`fixture hilang: ${skill}`);
}
for (const skill of baseline.runtime || []) {
  if (!state.runtime.includes(skill)) regressions.push(`verdict runtime hilang: ${skill}`);
}

const newRuntime = state.runtime.filter((skill) => !(baseline.runtime || []).includes(skill));
const newFixtures = state.fixtures.filter((skill) => !(baseline.fixtures || []).includes(skill));

console.log(summary);
if (newFixtures.length > 0) console.log(`  baru (fixture): ${newFixtures.join(', ')}`);
if (newRuntime.length > 0) console.log(`  baru (runtime): ${newRuntime.join(', ')}`);

if (regressions.length > 0) {
  console.error('  REGRESI:');
  for (const regression of regressions) console.error(`    - ${regression}`);
  console.error('  perbaiki skill-nya, atau perbarui baseline secara sadar: node bin/skill-coverage.js --update');
  process.exit(1);
}

const behind = [
  ...newFixtures.map((skill) => `+fixture ${skill}`),
  ...newRuntime.map((skill) => `+runtime ${skill}`),
];
if (behind.length > 0) {
  console.log(`  baseline belum mencatat: ${behind.join(', ')}`);
}
console.log('  tidak ada regresi cakupan');
