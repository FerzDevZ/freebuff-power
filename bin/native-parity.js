#!/usr/bin/env node
/**
 * Build a native-ownership matrix from two installed Pawn standard libraries.
 *
 *   node bin/native-parity.js --legacy /tmp/sampstdlib \
 *     --modern ~/samp-sdk/omp-stdlib \
 *     --out docs/NATIVE-PARITY.md --json bin/data/native-ownership.json
 *
 * The output answers one question per native: does it exist in 0.3.7, in
 * open.mp, in both, and did its signature change? The detector uses the JSON;
 * humans read the Markdown.
 */
'use strict';

const fs = require('fs');
const path = require('path');

function fail(message) {
  console.error(`native-parity: ${message}`);
  process.exit(2);
}

function parseArgs(argv) {
  const args = { legacy: '', modern: '', out: '', json: '' };
  for (let i = 0; i < argv.length; i++) {
    const key = argv[i];
    if (key === '--legacy') args.legacy = argv[++i] || '';
    else if (key === '--modern') args.modern = argv[++i] || '';
    else if (key === '--out') args.out = argv[++i] || '';
    else if (key === '--json') args.json = argv[++i] || '';
    else fail(`unknown argument '${key}'`);
  }
  if (!args.legacy || !args.modern) fail('--legacy and --modern are required');
  return args;
}

/** Collapses a Pawn parameter list to a comparable shape (types only). */
function shapeOf(params) {
  const parts = [];
  let depth = 0;
  let current = '';

  for (const ch of params) {
    if (ch === '{' || ch === '[' || ch === '(') depth++;
    if (ch === '}' || ch === ']' || ch === ')') depth--;
    if (ch === ',' && depth === 0) {
      parts.push(current);
      current = '';
      continue;
    }
    current += ch;
  }
  if (current.trim()) parts.push(current);

  return parts.map((raw) => {
    let text = raw.trim().replace(/\s+/g, ' ');
    /* Defaults never describe the contract. */
    const eq = text.indexOf('=');
    if (eq >= 0) text = text.slice(0, eq).trim();
    text = text.replace(/^const\s+/i, '').trim();
    if (!text) return '';

    /* name[] / Float:name / &Float:name / name */
    const isPlainName = /^[A-Za-z_]\w*$/.test(text);
    if (isPlainName) return '';

    const arrayMatch = text.match(/\[\s*\d*\s*\]$/);
    if (arrayMatch) {
      const head = text.slice(0, arrayMatch.index).trim();
      const tag = head.includes(':') ? head.slice(0, head.indexOf(':') + 1) : '';
      return `${tag}[]`;
    }

    const amp = text.startsWith('&') ? '&' : '';
    const body = amp ? text.slice(1) : text;
    const colon = body.indexOf(':');
    if (colon >= 0) return `${amp}${body.slice(0, colon + 1)}`;
    return `${amp}${body}`;
  }).join(',');
}

/**
 * Scans `native`/`forward` declarations with balanced parentheses, so a default
 * such as `len = sizeof (output)` cannot cut the parameter list short.
 */
function collectNatives(dir) {
  const files = fs.readdirSync(dir).filter((f) => f.endsWith('.inc'));
  const natives = new Map();
  const modernStocks = new Set();

  for (const file of files) {
    const source = fs
      .readFileSync(path.join(dir, file), 'utf8')
      .replace(/\/\*[\s\S]*?\*\//g, ' ')
      .replace(/\/\/[^\n]*/g, ' ');

    /* Deprecated replacements are `stock` shims declaring the same symbol. */
    const stockRe = /\b(?:static\s+)?stock\s+(?:[A-Za-z_]\w*:)?([A-Za-z_]\w*)\s*\(/g;
    let stockMatch;
    while ((stockMatch = stockRe.exec(source)) !== null) modernStocks.add(stockMatch[1]);

    const re = /\b(native|forward)\s+/g;
    let match;
    while ((match = re.exec(source)) !== null) {
      const kind = match[1];
      const head = source.slice(re.lastIndex).match(/^((?:[A-Za-z_]\w*:)?)([A-Za-z_]\w*)\s*\(/);
      if (!head) continue;

      const returnType = head[1];
      const name = head[2];
      if (name.startsWith('__')) continue;

      const openIndex = re.lastIndex + head[0].length - 1;
      let depth = 0;
      let closeIndex = -1;
      for (let i = openIndex; i < source.length; i++) {
        if (source[i] === '(') depth++;
        else if (source[i] === ')') {
          depth--;
          if (depth === 0) { closeIndex = i; break; }
        }
      }
      if (closeIndex < 0) continue;

      const tail = source.slice(closeIndex + 1);
      /* `native Old(...) = New;` is an alias and tells us nothing new. */
      if (/^\s*=/.test(tail)) continue;
      if (!/^\s*;/.test(tail)) continue;

      const params = source.slice(openIndex + 1, closeIndex).replace(/\s+/g, ' ').trim();
      natives.set(name, {
        name,
        kind,
        returnType,
        params,
        shape: shapeOf(params),
        library: file.replace(/\.inc$/, ''),
      });
    }
  }
  natives.stocks = modernStocks;
  return natives;
}

function compare(legacy, modern, legacyFiles) {
  const modernOnly = [];
  const unverified = [];
  const legacyOnly = [];
  const changed = [];
  const shared = [];

  for (const [name, entry] of modern) {
    if (!legacy.has(name)) {
      /* A missing legacy module (float.inc, string.inc…) means "cannot tell",
       * not "open.mp owns it". Only omp_* libraries are genuinely modern. */
      const libraryFile = `${entry.library}.inc`;
      if (!entry.library.startsWith('omp_') && !legacyFiles.has(libraryFile)) {
        unverified.push({ ...entry, reason: `module ${libraryFile} tidak ada di stdlib legacy` });
        continue;
      }
      modernOnly.push(entry);
      continue;
    }
    const old = legacy.get(name);
    shared.push({ name, modern: entry, legacy: old });
    if (old.shape !== entry.shape || old.returnType !== entry.returnType) {
      changed.push({ name, legacy: old, modern: entry });
    }
  }
  for (const [name, entry] of legacy) {
    if (!modern.has(name)) legacyOnly.push({ ...entry, shim: modern.stocks.has(name) });
  }

  const byName = (a, b) => a.name.localeCompare(b.name);
  modernOnly.sort(byName);
  unverified.sort(byName);
  legacyOnly.sort(byName);
  changed.sort(byName);
  return { modernOnly, unverified, legacyOnly, changed, shared };
}

function renderMarkdown(report) {
  const lines = [];
  lines.push('# Native parity: SA-MP 0.3.7 vs open.mp');
  lines.push('');
  lines.push(`Generated from \`${report.legacyDir}\` and \`${report.modernDir}\`.`);
  lines.push('');
  lines.push('| | Legacy 0.3.7 | open.mp |');
  lines.push('|---|---|---|');
  lines.push(`| Natives | ${report.counts.legacy} | ${report.counts.modern} |`);
  lines.push(`| Shared | ${report.counts.shared} | ${report.counts.shared} |`);
  lines.push(`| Only in this target | ${report.counts.legacyOnly} | ${report.counts.modernOnly} |`);
  lines.push(`| Unverifiable (module absent from legacy copy) | — | ${report.counts.unverified} |`);
  lines.push(`| Shared but reshaped | ${report.counts.changed} | ${report.counts.changed} |`);
  lines.push('');

  lines.push('## open.mp only — will not compile on 0.3.7');
  lines.push('');
  for (const entry of report.modernOnly) {
    lines.push(`- \`${entry.returnType}${entry.returnType.endsWith(':') ? '' : ' '}${entry.name}(${entry.params})\``);
  }
  lines.push('');

  lines.push('## Unverifiable — the legacy stdlib copy has no matching module');
  lines.push('');
  if (report.unverified.length === 0) {
    lines.push('_None._');
  } else {
    for (const entry of report.unverified) {
      lines.push(`- \`${entry.name}\` (${entry.reason})`);
    }
  }
  lines.push('');

  lines.push('## 0.3.7 only — removed or renamed in open.mp');
  lines.push('');
  if (report.legacyOnly.length === 0) {
    lines.push('_None detected._');
  } else {
    for (const entry of report.legacyOnly) {
      const note = entry.shim ? ' _(deprecated `stock` shim present)_' : '';
      lines.push(`- \`${entry.returnType} ${entry.name}(${entry.params})\`${note}`);
    }
  }
  lines.push('');

  lines.push('## Shared but reshaped — the signature is not interchangeable');
  lines.push('');
  if (report.changed.length === 0) {
    lines.push('_None detected._');
  } else {
    for (const entry of report.changed) {
      lines.push(`### \`${entry.name}\``);
      lines.push('');
      lines.push('| Target | Declaration |');
      lines.push('|---|---|');
      lines.push(`| 0.3.7 | \`${entry.legacy.returnType} ${entry.name}(${entry.legacy.params})\` |`);
      lines.push(`| open.mp | \`${entry.modern.returnType} ${entry.name}(${entry.modern.params})\` |`);
      lines.push('');
    }
  }
  return `${lines.join('\n')}\n`;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  for (const dir of [args.legacy, args.modern]) {
    if (!fs.existsSync(dir) || !fs.statSync(dir).isDirectory()) {
      fail(`not a directory: ${dir}`);
    }
  }

  const legacyFiles = new Set(fs.readdirSync(args.legacy));
  const legacy = collectNatives(args.legacy);
  const modern = collectNatives(args.modern);
  if (legacy.size === 0) fail(`no natives found in ${args.legacy}`);
  if (modern.size === 0) fail(`no natives found in ${args.modern}`);

  const diff = compare(legacy, modern, legacyFiles);
  const report = {
    legacyDir: args.legacy,
    modernDir: args.modern,
    counts: {
      legacy: legacy.size,
      modern: modern.size,
      shared: diff.shared.length,
      legacyOnly: diff.legacyOnly.length,
      modernOnly: diff.modernOnly.length,
      unverified: diff.unverified.length,
      changed: diff.changed.length,
    },
    modernOnly: diff.modernOnly,
    shared: diff.shared.map((entry) => entry.name).sort(),
    unverified: diff.unverified,
    legacyOnly: diff.legacyOnly,
    changed: diff.changed.map((entry) => ({
      name: entry.name,
      legacy: { returnType: entry.legacy.returnType, params: entry.legacy.params, shape: entry.legacy.shape },
      modern: { returnType: entry.modern.returnType, params: entry.modern.params, shape: entry.modern.shape },
    })),
  };

  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, renderMarkdown(report));
  }
  if (args.json) {
    fs.mkdirSync(path.dirname(args.json), { recursive: true });
    fs.writeFileSync(args.json, `${JSON.stringify(report, null, 2)}\n`);
  }

  console.log(
    `natives: legacy=${report.counts.legacy} modern=${report.counts.modern} ` +
    `shared=${report.counts.shared} modernOnly=${report.counts.modernOnly} ` +
    `unverified=${report.counts.unverified} ` +
    `legacyOnly=${report.counts.legacyOnly} changed=${report.counts.changed}`
  );
  if (args.out) console.log(`markdown: ${args.out}`);
  if (args.json) console.log(`json: ${args.json}`);
}

main();
