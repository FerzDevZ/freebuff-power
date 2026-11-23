#!/usr/bin/env node
/**
 * Decide whether Pawn source targets legacy SA-MP 0.3.7, modern open.mp, the
 * SAMP_COMPAT wrapper, or an inconsistent mix — before any code is written.
 *
 *   node bin/samp-detect.js path/to/script.pwn
 *   node bin/samp-detect.js /path/to/gamemode --json
 *
 * Verdicts: LEGACY | MODERN | COMPAT | MIXED | UNKNOWN
 * Exit code is 0 unless --strict is passed and an error-level finding exists.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const SOURCE_EXT = new Set(['.pwn', '.inc']);

/* Evidence weights. Includes decide the build; idioms only break ties. */
const WEIGHTS = {
  includeModern: 6,
  includeOmp: 4,
  includeLegacy: 5,
  compat: 8,
  modernNative: 2,
  legacyNative: 2,
  legacyIdiom: 1,
  modernIdiom: 1,
};

const LEGACY_INCLUDES = new Set(['a_samp', 'a_players', 'a_vehicles', 'a_objects', 'a_npc', 'a_sampdb', 'a_http']);

function parseArgs(argv) {
  const args = { paths: [], json: false, strict: false, ownership: path.join(__dirname, 'data', 'native-ownership.json') };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--json') args.json = true;
    else if (arg === '--strict') args.strict = true;
    else if (arg === '--ownership') args.ownership = argv[++i] || '';
    else if (arg.startsWith('--')) {
      console.error(`samp-detect: unknown argument '${arg}'`);
      process.exit(2);
    } else args.paths.push(arg);
  }
  if (args.paths.length === 0) {
    console.error('samp-detect: give at least one file or directory');
    process.exit(2);
  }
  return args;
}

function loadOwnership(file) {
  if (!file || !fs.existsSync(file)) return null;
  const data = JSON.parse(fs.readFileSync(file, 'utf8'));
  return {
    source: file,
    modernOnly: new Map(data.modernOnly.map((entry) => [entry.name, entry])),
    legacyOnly: new Map(data.legacyOnly.map((entry) => [entry.name, entry])),
    changed: new Map(data.changed.map((entry) => [entry.name, entry])),
  };
}

/** Removes comments and string literals while keeping line numbers intact. */
function stripNoise(source) {
  const lines = source.split('\n');
  let inBlock = false;
  return lines.map((line) => {
    let out = '';
    for (let i = 0; i < line.length; i++) {
      const two = line.slice(i, i + 2);
      if (inBlock) {
        if (two === '*/') { inBlock = false; i++; }
        continue;
      }
      if (two === '//') break;
      if (two === '/*') { inBlock = true; i++; continue; }
      if (line[i] === '"' || line[i] === "'") {
        const quote = line[i];
        i++;
        while (i < line.length && line[i] !== quote) {
          if (line[i] === '\\') i++;
          i++;
        }
        continue;
      }
      out += line[i];
    }
    return out;
  });
}

function scanFile(file, ownership) {
  const source = fs.readFileSync(file, 'utf8');
  const clean = stripNoise(source);
  const evidence = [];
  const findings = [];
  let modern = 0;
  let legacy = 0;
  let compat = false;
  let strongInclude = false;
  let hasModernInclude = false;
  let hasLegacyInclude = false;

  clean.forEach((line, index) => {
    const lineNo = index + 1;
    const includeMatch = line.match(/^\s*#\s*include\s*<([^>]+)>/);
    if (includeMatch) {
      const header = includeMatch[1].replace(/\\/g, '/').replace(/\.inc$/, '');
      const base = header.includes('/') ? header.slice(header.lastIndexOf('/') + 1) : header;
      if (base === 'open.mp' || base === '_open_mp') {
        modern += WEIGHTS.includeModern;
        strongInclude = true;
        hasModernInclude = true;
        evidence.push({ line: lineNo, text: line.trim(), kind: 'include', points: WEIGHTS.includeModern, target: 'modern' });
      } else if (base.startsWith('omp_')) {
        modern += WEIGHTS.includeOmp;
        strongInclude = true;
        hasModernInclude = true;
        evidence.push({ line: lineNo, text: line.trim(), kind: 'include', points: WEIGHTS.includeOmp, target: 'modern' });
      } else if (LEGACY_INCLUDES.has(base)) {
        legacy += WEIGHTS.includeLegacy;
        strongInclude = true;
        hasLegacyInclude = true;
        evidence.push({ line: lineNo, text: line.trim(), kind: 'include', points: WEIGHTS.includeLegacy, target: 'legacy' });
      }
    }

    if (/#\s*(?:define|if\s+defined)\s+SAMP_COMPAT\b/.test(line)) {
      compat = true;
      evidence.push({ line: lineNo, text: line.trim(), kind: 'compat', points: WEIGHTS.compat, target: 'compat' });
    }
  });

  /* Idioms that only exist in one era of the ecosystem. */
  const legacyIdioms = [
    { re: /\bstrtok\s*\(/, why: 'strtok() command parsing (legacy idiom; no native, hand-rolled in old gamemodes)' },
    { re: /\bdcmd_\w+/, why: 'dcmd_* command functions (legacy command processor)' },
    { re: /\bOnPlayerPrivmsg\b/, why: 'OnPlayerPrivmsg callback (removed after 0.3a)' },
  ];
  /* No "modern idiom" signals: `bool:` is a stock Pawn tag, not an open.mp
   * marker, and treating it as one mislabels portable libraries as modern. */
  let legacyIdiomPoints = 0;
  clean.forEach((line, index) => {
    for (const idiom of legacyIdioms) {
      if (legacyIdiomPoints >= 3) break;
      if (idiom.re.test(line)) {
        legacyIdiomPoints += WEIGHTS.legacyIdiom;
        evidence.push({ line: index + 1, text: line.trim(), kind: 'legacy-idiom', points: WEIGHTS.legacyIdiom, target: 'legacy', why: idiom.why });
      }
    }
  });
  legacy += legacyIdiomPoints;

  /* Native usage: the ownership matrix decides which target owns a symbol. */
  const usedModernOnly = [];
  const usedLegacyOnly = [];
  if (ownership) {
    const seen = new Set();
    clean.forEach((line, index) => {
      const callRe = /\b([A-Za-z_]\w*)\s*\(/g;
      let call;
      while ((call = callRe.exec(line)) !== null) {
        const name = call[1];
        if (seen.has(name)) continue;
        seen.add(name);
        if (ownership.modernOnly.has(name)) {
          usedModernOnly.push({ name, line: index + 1 });
        } else if (ownership.legacyOnly.has(name)) {
          usedLegacyOnly.push({ name, line: index + 1, shim: Boolean(ownership.legacyOnly.get(name).shim) });
        }
      }
    });
    modern += Math.min(usedModernOnly.length * WEIGHTS.modernNative, 8);
    legacy += Math.min(usedLegacyOnly.length * WEIGHTS.legacyNative, 8);
    for (const entry of usedModernOnly) {
      evidence.push({ line: entry.line, text: `${entry.name}()`, kind: 'modern-native', points: WEIGHTS.modernNative, target: 'modern' });
    }
    for (const entry of usedLegacyOnly) {
      evidence.push({ line: entry.line, text: `${entry.name}()`, kind: 'legacy-native', points: WEIGHTS.legacyNative, target: 'legacy' });
    }
  }

  /* A file that includes one header per preprocessor branch is a deliberate
   * dual-target build (the pattern every fixture in this repo uses), not a
   * half-finished migration. */
  const guardedBranches = /#\s*if[^\n]*\n[\s\S]{0,600}?#\s*(?:else|elseif)/i.test(clean.join('\n'));
  const dualTarget = hasModernInclude && hasLegacyInclude && guardedBranches;

  /* Includes decide the build. Symbol usage never flips a target on its own:
   * a legacy file calling a modern native is LEGACY plus an error, not MIXED. */
  let verdict;
  if (compat) verdict = 'COMPAT';
  else if (dualTarget) verdict = 'DUAL';
  else if (hasModernInclude && hasLegacyInclude) verdict = 'MIXED';
  else if (hasModernInclude) verdict = 'MODERN';
  else if (hasLegacyInclude) verdict = 'LEGACY';
  else if (modern > legacy) verdict = 'MODERN';
  else if (legacy > modern) verdict = 'LEGACY';
  else verdict = 'UNKNOWN';

  const confidence = strongInclude ? 'high' : verdict === 'UNKNOWN' ? 'none' : evidence.length > 0 ? 'medium' : 'low';

  if (verdict === 'LEGACY' || verdict === 'MIXED') {
    for (const entry of usedModernOnly) {
      findings.push({
        severity: 'error',
        line: entry.line,
        message: `${entry.name}() hanya ada di open.mp — target file ini legacy, jadi tidak akan lolos compile di 0.3.7.`,
      });
    }
  }
  if (verdict === 'MODERN' || verdict === 'MIXED') {
    for (const entry of usedLegacyOnly) {
      findings.push({
        severity: entry.shim ? 'warning' : 'error',
        line: entry.line,
        message: entry.shim
          ? `${entry.name}() bukan native lagi di open.mp, tetapi masih ada stock shim deprecated — pindahkan logikanya.`
          : `${entry.name}() dihapus dari open.mp dan tidak punya shim.`,
      });
    }
  }
  if (verdict === 'MIXED') {
    findings.push({
      severity: 'error',
      line: 1,
      message: 'Satu file memuat sinyal legacy dan modern sekaligus. Pilih satu target; jangan campur include <a_samp> dengan <open.mp>/omp_*.',
    });
  }
  if (verdict === 'UNKNOWN') {
    findings.push({
      severity: 'info',
      line: 1,
      message: 'Tidak ada include atau simbol yang menentukan target. Tambahkan <open.mp> atau <a_samp> secara eksplisit agar build-nya jelas.',
    });
  }
  if (verdict === 'COMPAT') {
    findings.push({
      severity: 'info',
      line: 1,
      message: 'SAMP_COMPAT: source legacy yang dijalankan di core open.mp. Native modern boleh dipakai, tetapi panggilan legacy tetap kompatibel.',
    });
  }
  if (verdict === 'DUAL') {
    findings.push({
      severity: 'info',
      line: 1,
      message: 'Dual-target: satu include per cabang #if, jadi file ini sengaja dibangun ke dua target. Jaga kedua cabang tetap sinkron dan kompilasi keduanya.',
    });
  }

  return {
    file,
    verdict,
    confidence,
    scores: { modern, legacy },
    evidence,
    findings,
    modernOnly: usedModernOnly.map((entry) => entry.name),
    legacyOnly: usedLegacyOnly.map((entry) => ({ name: entry.name, shim: entry.shim })),
  };
}

function walk(target, out) {
  const stat = fs.statSync(target);
  if (stat.isDirectory()) {
    for (const entry of fs.readdirSync(target, { withFileTypes: true })) {
      if (entry.isDirectory() && (entry.name === 'corpus' || entry.name === 'scenarios')) continue;
      if (entry.name.startsWith('.') || entry.name === 'node_modules') continue;
      walk(path.join(target, entry.name), out);
    }
    return out;
  }
  if (SOURCE_EXT.has(path.extname(target))) out.push(target);
  return out;
}

function detectProjectConfig(target) {
  if (!fs.statSync(target).isDirectory()) return { legacyConfig: false, modernConfig: false, notes: [] };
  const legacyConfig = fs.existsSync(path.join(target, 'server.cfg'));
  const configPath = path.join(target, 'config.json');
  let modernConfig = false;
  const notes = [];

  if (fs.existsSync(configPath)) {
    try {
      const parsed = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      modernConfig = Boolean(parsed && parsed.pawn);
      if (!modernConfig) notes.push('config.json ada tetapi tanpa blok "pawn" — bukan config open.mp yang valid.');
    } catch (error) {
      notes.push(`config.json tidak bisa diparse: ${error.message}`);
    }
  }
  return { legacyConfig, modernConfig, notes };
}

function renderText(result, ownership) {
  const lines = [];
  const label = {
    LEGACY: 'LEGACY 0.3.7',
    MODERN: 'MODERN open.mp',
    COMPAT: 'COMPAT (legacy source di core open.mp)',
    MIXED:    'MIXED — tidak akan compile di salah satu target',
    DUAL: 'DUAL-TARGET (satu include per cabang)',
    UNKNOWN: 'UNKNOWN',
  };

  for (const file of result.files) {
    lines.push(`${file.file}: ${label[file.verdict]} (confidence ${file.confidence}, modern=${file.scores.modern} legacy=${file.scores.legacy})`);
    for (const entry of file.evidence.slice(0, 8)) {
      const why = entry.why ? ` — ${entry.why}` : '';
      lines.push(`    L${entry.line}  +${entry.points} ${entry.target.padEnd(7)} ${entry.kind}: ${entry.text}${why}`);
    }
    for (const finding of file.findings) {
      lines.push(`    ${finding.severity.toUpperCase()} L${finding.line}: ${finding.message}`);
    }
    lines.push('');
  }

  if (result.project) {
    lines.push(`project: ${result.project.kind}`);
    for (const note of result.project.notes) lines.push(`    ${note}`);
    lines.push('');
  }

  if (!ownership) {
    lines.push('catatan: matriks native tidak ditemukan — sinyal native dilewati. Jalankan bin/native-parity.js.');
  }

  const counts = result.files.reduce((acc, file) => {
    acc[file.verdict] = (acc[file.verdict] || 0) + 1;
    return acc;
  }, {});
  lines.push(`ringkasan: ${Object.entries(counts).map(([key, value]) => `${key}=${value}`).join(' ') || 'tidak ada file'}`);
  return lines.join('\n');
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const ownership = loadOwnership(args.ownership);

  const files = [];
  for (const target of args.paths) {
    if (!fs.existsSync(target)) {
      console.error(`samp-detect: not found: ${target}`);
      process.exit(2);
    }
    walk(target, files);
  }
  if (files.length === 0) {
    console.error('samp-detect: no .pwn/.inc files found');
    process.exit(2);
  }

  const scanned = files.sort().map((file) => scanFile(file, ownership));
  let project = null;
  for (const target of args.paths) {
    const config = detectProjectConfig(target);
    if (!config.legacyConfig && !config.modernConfig && config.notes.length === 0) continue;
    const kind = config.legacyConfig && config.modernConfig
      ? 'HYBRID — server.cfg dan config.json hidup bersama (migrasi setengah jalan)'
      : config.modernConfig
        ? 'MODERN — config.json milik open.mp'
        : 'LEGACY — server.cfg milik 0.3.7';
    project = { kind, notes: config.notes, legacyConfig: config.legacyConfig, modernConfig: config.modernConfig };
  }

  const result = { files: scanned, project };
  if (args.json) {
    console.log(JSON.stringify(result, null, 2));
  } else {
    console.log(renderText(result, ownership));
  }

  const errors = scanned.flatMap((file) => file.findings).filter((finding) => finding.severity === 'error');
  if (args.strict && errors.length > 0) process.exit(1);
}

main();
