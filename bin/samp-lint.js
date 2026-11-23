#!/usr/bin/env node
/**
 * Static security lint for SA-MP/open.mp Pawn sources.
 *
 *   node bin/samp-lint.js gamemodes/
 *   node bin/samp-lint.js .agents/skills --json --fail-on=error
 *
 * Every rule here is line/structure based and deliberately narrow: a rule that
 * fires on safe code is worse than no rule, so the corpus in
 * samp-security-lint/corpus pins both directions (must flag / must not flag).
 *
 * Not a dataflow analyser: no macro expansion, no cross-file taint tracking.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const SOURCE_EXT = new Set(['.pwn', '.inc']);
const CONFIG_NAMES = new Set(['config.json', 'server.cfg']);

/* Identifiers that carry client-controlled text in this domain. */
const USER_INPUT = new Set(['inputtext', 'cmdtext', 'params', 'text', 'name']);
const WEAK_PASSWORDS = new Set(['', 'changeme', 'password', 'rcon', '123', '1234', '12345', '123456', 'admin', 'test']);

const RULES = {
  'format-injection': {
    severity: 'error',
    message: 'format() memakai input klien sebagai format string — selalu "%s" lalu nilainya.',
  },
  'mysql-percent-s': {
    severity: 'error',
    message: 'mysql_format memakai %s untuk string — pakai %e agar nilai di-escape.',
  },
  'dialog-unguarded': {
    severity: 'error',
    message: 'OnDialogResponse tidak memvalidasi dialogid — klien bisa memalsukan respons.',
  },
  'poolsize-loop': {
    severity: 'warning',
    message: 'GetPlayerPoolSize() hanya stock shim deprecated di open.mp — pakai MAX_PLAYERS/foreach.',
  },
  'weak-rcon': {
    severity: 'error',
    message: 'Password RCON lemah/kosong — server bisa diambil alih.',
  },
};

function parseArgs(argv) {
  const args = { paths: [], json: false, failOn: 'error', includeCorpus: false };
  for (const arg of argv) {
    if (arg === '--json') args.json = true;
    else if (arg === '--include-corpus') args.includeCorpus = true;
    else if (arg.startsWith('--fail-on=')) {
      args.failOn = arg.slice('--fail-on='.length);
      if (!['error', 'warning', 'none'].includes(args.failOn)) {
        console.error(`samp-lint: --fail-on must be error|warning|none`);
        process.exit(2);
      }
    } else if (arg.startsWith('--')) {
      console.error(`samp-lint: unknown argument '${arg}'`);
      process.exit(2);
    } else args.paths.push(arg);
  }
  if (args.paths.length === 0) args.paths = ['.'];
  return args;
}

/** Strips // and block comments, keeping line numbers and string contents. */
function stripComments(source) {
  let inBlock = false;
  return source.split('\n').map((line) => {
    let out = '';
    for (let i = 0; i < line.length; i++) {
      const two = line.slice(i, i + 2);
      if (inBlock) {
        if (two === '*/') { inBlock = false; i++; }
        continue;
      }
      if (two === '//') break;
      if (two === '/*') { inBlock = true; i++; continue; }
      if (line[i] === '"') {
        out += line[i];
        i++;
        while (i < line.length && line[i] !== '"') {
          if (line[i] === '\\') { out += line[i++]; }
          out += line[i];
          i++;
        }
        out += line[i] || '';
        continue;
      }
      out += line[i];
    }
    return out;
  });
}

/** Splits a call's argument list at top-level commas, respecting quotes/parens. */
function splitArgs(text) {
  const args = [];
  let current = '';
  let depth = 0;
  let quoted = false;

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      current += ch;
      if (ch === '\\') { current += text[++i] || ''; continue; }
      if (ch === '"') quoted = false;
      continue;
    }
    if (ch === '"') { quoted = true; current += ch; continue; }
    if (ch === '(' || ch === '[' || ch === '{') depth++;
    if (ch === ')' || ch === ']' || ch === '}') depth--;
    if (ch === ',' && depth === 0) { args.push(current.trim()); current = ''; continue; }
    current += ch;
  }
  if (current.trim()) args.push(current.trim());
  return args;
}

/** Finds `name(...)` calls on one line and returns their argument lists. */
function callsOnLine(line, name) {
  const out = [];
  const re = new RegExp(`\\b${name}\\s*\\(`, 'g');
  let match;
  while ((match = re.exec(line)) !== null) {
    const open = match.index + match[0].length - 1;
    let depth = 0;
    let quoted = false;
    for (let i = open; i < line.length; i++) {
      const ch = line[i];
      if (quoted) {
        if (ch === '\\') i++;
        else if (ch === '"') quoted = false;
        continue;
      }
      if (ch === '"') { quoted = true; continue; }
      if (ch === '(') depth++;
      else if (ch === ')') {
        depth--;
        if (depth === 0) {
          out.push(splitArgs(line.slice(open + 1, i)));
          break;
        }
      }
    }
  }
  return out;
}

function lintPawn(file) {
  const findings = [];
  const raw = fs.readFileSync(file, 'utf8');
  const lines = stripComments(raw);
  const joined = lines.join('\n');

  lines.forEach((line, index) => {
    for (const args of callsOnLine(line, 'format')) {
      /* format(output, len, fmt, ...) */
      const fmt = args[2];
      if (fmt && /^[A-Za-z_]\w*$/.test(fmt) && USER_INPUT.has(fmt)) {
        findings.push({ file, line: index + 1, rule: 'format-injection', severity: RULES['format-injection'].severity, message: RULES['format-injection'].message });
      }
    }

    for (const args of callsOnLine(line, 'mysql_format')) {
      /* mysql_format(handle, output, len, fmt, ...) */
      const fmt = args[3];
      if (fmt && fmt.startsWith('"') && /%s/.test(fmt) && !/%e/.test(fmt)) {
        findings.push({ file, line: index + 1, rule: 'mysql-percent-s', severity: RULES['mysql-percent-s'].severity, message: RULES['mysql-percent-s'].message });
      }
    }

    if (/\bGet(?:Player|Vehicle|Actor)PoolSize\s*\(/.test(line)) {
      findings.push({ file, line: index + 1, rule: 'poolsize-loop', severity: RULES['poolsize-loop'].severity, message: RULES['poolsize-loop'].message });
    }
  });

  if (/\bpublic\s+OnDialogResponse\s*\(/.test(joined)) {
    const bodyStart = joined.indexOf('OnDialogResponse');
    const body = joined.slice(bodyStart);
    /* Any real use of dialogid: comparison, switch, array index, or a guard call. */
    const validatesId = /\bdialogid\s*(?:==|!=|<|>|<=|>=)/.test(body)
      || /\bswitch\s*\(\s*dialogid\s*\)/.test(body)
      || /\bDG_(?:CanRespond|Accept|ActiveId)\s*\(/.test(body);
    const mentionsListitemGuard = /\blistitem\s*(?:<|>|<=|>=)/.test(body);

    if (!validatesId) {
      const line = joined.slice(0, bodyStart).split('\n').length;
      findings.push({ file, line, rule: 'dialog-unguarded', severity: RULES['dialog-unguarded'].severity, message: RULES['dialog-unguarded'].message });
    } else if (!mentionsListitemGuard && /\blistitem\b/.test(body)) {
      /* Softer, same rule family: id checked but the list index is trusted. */
      findings.push({
        file,
        line: joined.slice(0, bodyStart).split('\n').length,
        rule: 'dialog-unguarded',
        severity: 'warning',
        message: 'listitem dipakai tanpa batas — indeks dari klien bisa di luar daftar.',
      });
    }
  }

  return findings;
}

function lintConfig(file) {
  const findings = [];
  const name = path.basename(file);

  if (name === 'config.json') {
    let parsed;
    try {
      parsed = JSON.parse(fs.readFileSync(file, 'utf8'));
    } catch (error) {
      return [{ file, line: 1, rule: 'weak-rcon', severity: 'warning', message: `config.json tidak bisa diparse: ${error.message}` }];
    }
    /* Only server configs are in scope: a config.json without an `rcon` block
     * belongs to tooling and must not be judged as a server. */
    if (!parsed || typeof parsed !== 'object' || !parsed.rcon) return findings;

    const password = typeof parsed.rcon.password === 'string' ? parsed.rcon.password : '';
    if (password.length < 8 || WEAK_PASSWORDS.has(password.toLowerCase())) {
      findings.push({ file, line: 1, rule: 'weak-rcon', severity: RULES['weak-rcon'].severity, message: RULES['weak-rcon'].message });
    }
    return findings;
  }

  const lines = fs.readFileSync(file, 'utf8').split('\n');
  lines.forEach((line, index) => {
    const match = line.match(/^\s*rcon_password\s+(\S*)\s*$/);
    if (!match) return;
    const password = match[1].replace(/^"|"$/g, '');
    if (password.length < 8 || WEAK_PASSWORDS.has(password.toLowerCase())) {
      findings.push({ file, line: index + 1, rule: 'weak-rcon', severity: RULES['weak-rcon'].severity, message: RULES['weak-rcon'].message });
    }
  });
  return findings;
}

function walk(target, out, includeCorpus) {
  const stat = fs.statSync(target);
  if (stat.isDirectory()) {
    for (const entry of fs.readdirSync(target, { withFileTypes: true })) {
      if (entry.name.startsWith('.') || entry.name === 'node_modules') continue;
      const full = path.join(target, entry.name);
      /* corpus/ and scenarios/ are deliberately bad inputs; scanning them would
       * report the eval fixtures as repository defects. */
      if (entry.isDirectory() && (entry.name === 'scenarios' || (!includeCorpus && entry.name === 'corpus'))) continue;
      walk(full, out, includeCorpus);
    }
    return out;
  }
  if (SOURCE_EXT.has(path.extname(target)) || CONFIG_NAMES.has(path.basename(target))) out.push(target);
  return out;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const files = [];

  for (const target of args.paths) {
    if (!fs.existsSync(target)) {
      console.error(`samp-lint: not found: ${target}`);
      process.exit(2);
    }
    walk(target, files, args.includeCorpus);
  }

  const findings = files.flatMap((file) => {
    if (path.basename(file) === 'config.json' || path.basename(file) === 'server.cfg') return lintConfig(file);
    return lintPawn(file);
  });

  if (args.json) {
    console.log(JSON.stringify({ files: files.length, findings }, null, 2));
  } else if (findings.length === 0) {
    console.log(`samp-lint: ${files.length} file, 0 temuan`);
  } else {
    for (const finding of findings) {
      console.log(`${finding.severity.toUpperCase()} ${finding.file}:${finding.line} [${finding.rule}] ${finding.message}`);
    }
    const errors = findings.filter((finding) => finding.severity === 'error').length;
    console.log(`samp-lint: ${files.length} file, ${findings.length} temuan (${errors} error)`);
  }

  const errors = findings.filter((finding) => finding.severity === 'error').length;
  const warnings = findings.length - errors;
  if (args.failOn === 'error' && errors > 0) process.exit(1);
  if (args.failOn === 'warning' && (errors > 0 || warnings > 0)) process.exit(1);
}

main();
