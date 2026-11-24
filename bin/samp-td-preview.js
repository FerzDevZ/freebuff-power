#!/usr/bin/env node
// ==============================================================================
// 🎨 SA-MP / open.mp 16:9 VISUAL TEXTDRAW PREVIEWER (v11.3)
// Parses CreatePlayerTextDraw / TextDrawCreate calls in a .pwn/.inc file and
// renders an interactive 16:9 HTML5 Canvas mockup with hitbox & mobile safe zones.
// Usage: freepi-power samp td-preview <file.pwn> [output.html]
// ==============================================================================
const fs = require("fs");
const path = require("path");

const args = process.argv.slice(2);
if (args.length === 0 || args[0] === "-h" || args[0] === "--help") {
  console.log("Penggunaan: freepi-power samp td-preview <file.pwn> [output.html]");
  console.log("Contoh:     freepi-power samp td-preview gamemodes/modules/ui/fivem_hud.pwn");
  process.exit(0);
}

const inputPath = path.resolve(args[0]);
if (!fs.existsSync(inputPath)) {
  console.error(`❌ File tidak ditemukan: ${inputPath}`);
  process.exit(1);
}

const outputPath = path.resolve(
  args[1] || path.join(path.dirname(inputPath), `${path.basename(inputPath, path.extname(inputPath))}_preview.html`)
);

const source = fs.readFileSync(inputPath, "utf8");

// 1. Collect #define hex color constants & numeric constants
const defines = new Map();
const defineRegex = /^\s*#define\s+([A-Za-z_][A-Za-z0-9_]*)\s+\(?([0-9xXa-fA-F.+-]+)\)?/gm;
let m;
while ((m = defineRegex.exec(source)) !== null) {
  defines.set(m[1], m[2]);
}

function resolveToken(tok) {
  if (!tok) return "";
  const cleaned = tok.trim().replace(/^\(|\)$/g, "");
  return defines.has(cleaned) ? defines.get(cleaned) : cleaned;
}

function parseFloatVal(tok, fallback = 0) {
  const val = parseFloat(resolveToken(tok));
  return Number.isFinite(val) ? val : fallback;
}

function rgbaHexToCss(tok, fallback = "rgba(248, 250, 252, 1)") {
  const resolved = resolveToken(tok);
  const match = resolved.match(/^0x([0-9a-fA-F]{8})$/);
  if (!match) return fallback;
  const hex = match[1];
  const r = parseInt(hex.slice(0, 2), 16);
  const g = parseInt(hex.slice(2, 4), 16);
  const b = parseInt(hex.slice(4, 6), 16);
  const a = +(parseInt(hex.slice(6, 8), 16) / 255).toFixed(3);
  return `rgba(${r}, ${g}, ${b}, ${a})`;
}

// 2. Parse CreatePlayerTextDraw and TextDrawCreate
/* One entry per create call, in source order. The same variable name is
 * routinely reused (`pv = CreatePlayerTextDraw(...)` in a mirror block), so
 * keying by name collapsed N elements into 1; setters now attach to the most
 * recent create for that name, which matches how the engine binds them. */
const elements = [];
const lastByVar = new Map();
const createRegex = /([A-Za-z0-9_\[\]]+)\s*=\s*(CreatePlayerTextDraw|TextDrawCreate)\s*\(([^;]+)\)\s*;/g;
while ((m = createRegex.exec(source)) !== null) {
  const varName = m[1].trim();
  const kind = m[2] === "CreatePlayerTextDraw" ? "player" : "global";
  const rawArgs = m[3].split(",");
  const offset = kind === "player" ? 1 : 0;
  if (rawArgs.length < offset + 3) continue;
  const x = parseFloatVal(rawArgs[offset], 0);
  const y = parseFloatVal(rawArgs[offset + 1], 0);
  const textRaw = rawArgs.slice(offset + 2).join(",").trim().replace(/^"|"$/g, "");
  const seen = (lastByVar.get(varName)?.seq || 0) + 1;
  const el = {
    id: seen > 1 ? `${varName}#${seen}` : varName,
    seq: seen,
    kind,
    x,
    y,
    text: textRaw,
    w: 60,
    h: 16,
    letterX: 0.2,
    letterY: 0.9,
    font: 1,
    align: 1,
    useBox: false,
    selectable: false,
    color: "rgba(248, 250, 252, 1)",
    boxColor: "rgba(15, 23, 42, 0.85)",
    bgColor: "rgba(0, 0, 0, 1)", // engine default is opaque black
    bgSet: false,
    boxSet: false,
    letterSet: false,
    sizeSet: false
  };
  elements.push(el);
  lastByVar.set(varName, el);
}

// 3. Parse property setters
const propRegex = /(PlayerTextDraw|TextDraw)(Font|Alignment|TextSize|LetterSize|Color|BoxColor|BackgroundColor|UseBox|SetSelectable)\s*\(([^;]+)\)\s*;/g;
while ((m = propRegex.exec(source)) !== null) {
  const isPlayer = m[1] === "PlayerTextDraw";
  const prop = m[2];
  const rawArgs = m[3].split(",").map((s) => s.trim());
  const offset = isPlayer ? 1 : 0;
  const varName = rawArgs[offset];
  const el = lastByVar.get(varName);
  if (!el) continue;

  if (prop === "Font") {
    const f = rawArgs[offset + 1] || "1";
    if (/SPRITE|4/.test(f)) el.font = 4;
    else if (/MODEL|5/.test(f)) el.font = 5;
    else if (/2/.test(f)) el.font = 2;
    else if (/3/.test(f)) el.font = 3;
    else if (/0/.test(f)) el.font = 0;
    else el.font = 1;
  } else if (prop === "Alignment") {
    const a = rawArgs[offset + 1] || "1";
    if (/CENTER|2/.test(a)) el.align = 2;
    else if (/RIGHT|3/.test(a)) el.align = 3;
    else el.align = 1;
  } else if (prop === "TextSize") {
    el.w = parseFloatVal(rawArgs[offset + 1], el.w);
    el.h = parseFloatVal(rawArgs[offset + 2], el.h);
    el.sizeSet = true;
  } else if (prop === "LetterSize") {
    el.letterX = parseFloatVal(rawArgs[offset + 1], el.letterX);
    el.letterY = parseFloatVal(rawArgs[offset + 2], el.letterY);
    el.letterSet = true;
  } else if (prop === "Color") {
    el.color = rgbaHexToCss(rawArgs[offset + 1], el.color);
  } else if (prop === "BoxColor") {
    el.boxColor = rgbaHexToCss(rawArgs[offset + 1], el.boxColor);
    el.boxSet = true;
  } else if (prop === "BackgroundColor") {
    el.bgColor = rgbaHexToCss(rawArgs[offset + 1], el.bgColor);
    el.bgSet = true;
    el.bgAlpha = el.bgColor;
  } else if (prop === "UseBox") {
    el.useBox = rawArgs[offset + 1] === "1" || rawArgs[offset + 1] === "true";
  } else if (prop === "SetSelectable") {
    el.selectable = rawArgs[offset + 1] === "1" || rawArgs[offset + 1] === "true";
  }
}

const list = elements;
const playerCount = list.filter((e) => e.kind === "player").length;
const globalCount = list.filter((e) => e.kind === "global").length;

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>SA-MP / open.mp 16:9 TextDraw Preview — ${path.basename(inputPath)}</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: #090d16; color: #e2e8f0; font-family: ui-sans-serif, system-ui, -apple-system, sans-serif; padding: 20px; }
  .bar { display: flex; flex-wrap: wrap; gap: 14px; align-items: center; justify-content: space-between; max-width: 1280px; margin: 0 auto 14px; padding: 12px 16px; background: #111827; border: 1px solid #1f2937; border-radius: 10px; }
  .title { font-weight: 700; font-size: 15px; color: #f8fafc; }
  .meta { font-size: 13px; color: #94a3b8; display: flex; gap: 16px; align-items: center; }
  .badge { padding: 3px 9px; border-radius: 6px; font-weight: 600; font-size: 12px; background: #1e293b; color: #10b981; }
  .badge.warn { color: #f59e0b; }
  .controls { display: flex; gap: 12px; font-size: 13px; }
  label { display: inline-flex; gap: 6px; align-items: center; cursor: pointer; }
  .stage { position: relative; max-width: 1280px; margin: 0 auto; border-radius: 10px; overflow: hidden; border: 1px solid #334155; background: radial-gradient(circle at 30% 20%, #1e293b 0%, #0b1120 75%); }
  canvas { width: 100%; height: auto; display: block; }
  .inspector { max-width: 1280px; margin: 12px auto 0; padding: 10px 16px; background: #111827; border: 1px solid #1f2937; border-radius: 8px; font-family: ui-monospace, monospace; font-size: 12px; color: #cbd5e1; }
</style>
</head>
<body>
  <div class="bar">
    <div>
      <div class="title">SA-MP / open.mp 16:9 TextDraw Preview — ${path.basename(inputPath)}</div>
      <div class="meta">
        <span>Canvas: 640×480 → 1280×720 (16:9)</span>
        <span class="badge ${playerCount > 200 ? "warn" : ""}">PlayerTD: ${playerCount} / 256</span>
        <span class="badge">GlobalTD: ${globalCount} / 2048</span>
      </div>
    </div>
    <div class="controls">
      <label><input type="checkbox" id="chkGrid" checked /> 640×480 Grid</label>
      <label><input type="checkbox" id="chkHitbox" checked /> Hitboxes</label>
      <label><input type="checkbox" id="chkMobile" /> Android Safe Zones</label>
      <label><input type="checkbox" id="chkInset" checked /> Engine box inset (−5,−10)</label>
    </div>
  </div>
  <div class="stage"><canvas id="cv" width="1280" height="720"></canvas></div>
  <div class="inspector" id="insp">Arahkan kursor di atas kanvas untuk melihat koordinat 640×480 & elemen TextDraw.</div>
  <div class="inspector" id="diag"></div>
<script>
const ITEMS = ${JSON.stringify(list)};
const cv = document.getElementById("cv");
const ctx = cv.getContext("2d");
const insp = document.getElementById("insp");
const SX = 1280 / 640, SY = 720 / 480;
const ISSUES = [];
const diag = document.getElementById("diag");

// Engine truth: TextDrawTextSize means different things per alignment/font.
function geo(el) {
  const insetOn = document.getElementById("chkInset").checked;
  const ox = insetOn ? 5 : 0, oy = insetOn ? 10 : 0;
  if (el.font === 4 || el.font === 5) return { x: el.x, y: el.y, w: el.w, h: el.h };
  if (!el.sizeSet) return { x: el.x, y: el.y, w: 0, h: 0 };
  if (el.align === 2) return { x: el.x - el.w / 2 - ox, y: el.y - oy, w: el.w, h: el.h };
  if (el.align === 3) return { x: el.w - ox, y: el.y - oy, w: el.x - el.w, h: el.h };
  return { x: el.x - ox, y: el.y - oy, w: el.w - el.x, h: el.h };
}

function draw() {
  ctx.clearRect(0, 0, 1280, 720);
  if (document.getElementById("chkGrid").checked) {
    ctx.strokeStyle = "rgba(148,163,184,0.12)";
    ctx.lineWidth = 1;
    for (let x = 0; x <= 640; x += 40) { ctx.beginPath(); ctx.moveTo(x*SX, 0); ctx.lineTo(x*SX, 720); ctx.stroke(); }
    for (let y = 0; y <= 480; y += 40) { ctx.beginPath(); ctx.moveTo(0, y*SY); ctx.lineTo(1280, y*SY); ctx.stroke(); }
  }
  if (document.getElementById("chkMobile").checked) {
    ctx.fillStyle = "rgba(239,68,68,0.14)";
    ctx.fillRect(0, 310*SY, 165*SX, 170*SY);
    ctx.fillRect(475*SX, 280*SY, 165*SX, 200*SY);
    ctx.fillStyle = "rgba(248,113,113,0.9)";
    ctx.font = "600 12px sans-serif";
    ctx.fillText("ANDROID JOYSTICK ZONE", 16, 330*SY);
    ctx.fillText("ANDROID TOUCH BUTTONS", 485*SX, 300*SY);
  }
  ISSUES.length = 0;
  for (const el of ITEMS) {
    const g = geo(el);
    const px = g.x * SX, py = g.y * SY, pw = g.w * SX, ph = g.h * SY;
    const showHit = el.selectable && document.getElementById("chkHitbox").checked;
    const hasArea = g.w >= 1 && g.h >= 1;

    if (el.font === 4) {
      if (!hasArea) { ISSUES.push("ERROR " + el.id + ": sprite " + g.w.toFixed(1) + "x" + g.h.toFixed(1) + " -> tidak pernah dirender (min 1.0)"); continue; }
      ctx.fillStyle = el.color;
      if (/chit/i.test(el.text)) {
        ctx.beginPath();
        ctx.ellipse(px + pw/2, py + ph/2, Math.abs(pw)/2, Math.abs(ph)/2, 0, 0, Math.PI*2);
        ctx.fill();
      } else {
        ctx.fillRect(px, py, pw, ph);
      }
    } else if (el.font === 5) {
      if (!hasArea) { ISSUES.push("ERROR " + el.id + ": model preview " + g.w.toFixed(1) + "x" + g.h.toFixed(1) + " -> tidak pernah dirender"); continue; }
      ctx.fillStyle = el.bgSet ? el.bgColor : "rgba(0,0,0,1)";
      ctx.fillRect(px, py, pw, ph);
      ctx.strokeStyle = "rgba(255,255,255,0.22)"; ctx.strokeRect(px, py, pw, ph);
      ctx.fillStyle = "#94a3b8"; ctx.font = "11px monospace"; ctx.fillText("3D", px + 6, py + 16);
    } else {
      if (el.useBox && hasArea) {
        ctx.fillStyle = el.boxColor;
        ctx.fillRect(px, py, pw, ph);
      }
      ctx.fillStyle = el.color;
      ctx.font = (el.font === 2 ? "700 " : "500 ") + Math.max(10, Math.round(el.letterY * 16)) + "px sans-serif";
      ctx.textAlign = el.align === 2 ? "center" : (el.align === 3 ? "right" : "left");
      const tx = el.align === 2 ? el.x * SX : (el.align === 3 ? px + pw : px);
      ctx.fillText(el.text.replace(/~[a-zA-Z]~/g, ""), tx, py + Math.max(12, el.letterY * 15));
      ctx.textAlign = "left";

      if (!el.letterSet) ISSUES.push("ERROR " + el.id + ": LetterSize tidak diset -> default 0.0, teks tidak terlihat");
      if (!el.bgSet) ISSUES.push("WARN " + el.id + ": BackgroundColor default hitam opaque -> kotak hitam di belakang teks");
      if (el.useBox && !el.boxSet) ISSUES.push("WARN " + el.id + ": UseBox aktif tapi BoxColor tidak diset (default gelap)");
      if (el.useBox && el.sizeSet && g.w < 1) ISSUES.push("ERROR " + el.id + ": align LEFT tapi TextSize.x (" + el.w + ") < Create.x (" + el.x + ") -> box & hitbox terbalik");
      if (el.selectable && !el.sizeSet) ISSUES.push("ERROR " + el.id + ": selectable tanpa TextSize -> area klik 0, klik tidak pernah kena");
    }

    if (showHit && hasArea) {
      ctx.strokeStyle = "#38bdf8"; ctx.setLineDash([4,3]); ctx.strokeRect(px, py, pw, ph); ctx.setLineDash([]);
    }
    if (el.x < 0 || el.y < 0 || el.x > 640 || el.y > 480) ISSUES.push("WARN " + el.id + ": create pos di luar kanvas 640x480");
    if (el.selectable && document.getElementById("chkMobile").checked && (el.x < 190 && el.y + g.h > 300 || el.x + g.w > 450 && el.y + g.h > 270))
      ISSUES.push("ERROR " + el.id + ": elemen bisa diklik masuk zona sentuh Android");
  }

  if (ISSUES.length === 0) {
    diag.style.color = "#10b981";
    diag.textContent = "Layout gate: tidak ada masalah geometri terdeteksi (" + ITEMS.length + " elemen).";
  } else {
    diag.style.color = "#f59e0b";
    diag.textContent = "Layout gate: " + ISSUES.length + " masalah -> " + ISSUES.join("  |  ");
  }
}

cv.addEventListener("mousemove", (ev) => {
  const rect = cv.getBoundingClientRect();
  const sx = ((ev.clientX - rect.left) / rect.width) * 640;
  const sy = ((ev.clientY - rect.top) / rect.height) * 480;
  const hit = ITEMS.find((e) => {
    const g = geo(e);
    return g.w >= 1 && g.h >= 1 && sx >= g.x && sx <= g.x + g.w && sy >= g.y && sy <= g.y + g.h;
  });
  insp.textContent = \`Cursor: (\${sx.toFixed(1)}, \${sy.toFixed(1)}) / 640x480\` + (hit ? (() => { const g = geo(hit); return \`  |  Hover: \${hit.id} [\${hit.kind}] Font:\${hit.font} Align:\${hit.align} Rect:(\${g.x.toFixed(1)},\${g.y.toFixed(1)},\${g.w.toFixed(1)},\${g.h.toFixed(1)}) Selectable:\${hit.selectable}\`; })() : "");
});
["chkGrid", "chkHitbox", "chkMobile", "chkInset"].forEach((id) => document.getElementById(id).addEventListener("change", draw));
draw();
</script>
</body>
</html>`;

fs.writeFileSync(outputPath, html, "utf8");
if (list.length === 0) {
  console.error("❌ [SAMP TD-PREVIEW] 0 TextDraw ditemukan.");
  console.error("   Parser hanya membaca pemanggilan INLINE `var = CreatePlayerTextDraw(...)` / `TextDrawCreate(...)`.");
  console.error("   Jika layout dibuat lewat stock/helper, tambahkan blok mirror `#if defined TD_PREVIEW_MIRROR`.");
  process.exit(2);
}
console.log(`✅ [SAMP TD-PREVIEW] ${list.length} TextDraws (${playerCount} PlayerTD, ${globalCount} GlobalTD) dirender ke:`);
console.log(`   ${outputPath}`);
if (playerCount > 200) {
  console.log(`⚠️  PERINGATAN: ${playerCount}/256 PlayerTextDraw mendekati batas engine! Pindahkan frame statis ke Global TextDraw.`);
}
