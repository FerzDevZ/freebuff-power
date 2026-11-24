#!/usr/bin/env node
// ==============================================================================
// 🏗️ SA-MP / open.mp MAPPING AUTO-UPGRADER (Legacy Dump -> Modern 2026 MLO)
// Usage: freepi-power samp map-upgrade <input.pwn> [output.pwn] [--interior]
// ==============================================================================
const fs = require("fs");
const path = require("path");

const args = process.argv.slice(2);
if (args.length === 0 || args[0] === "-h" || args[0] === "--help") {
  console.log("Penggunaan: freepi-power samp map-upgrade <input.pwn> [output.pwn] [--interior]");
  console.log("Contoh:     freepi-power samp map-upgrade maps/bank_old.pwn maps/bank_mlo_2026.pwn --interior");
  process.exit(0);
}

const isInterior = args.includes("--interior");
const positional = args.filter((a) => !a.startsWith("--"));
const inputPath = path.resolve(positional[0]);

if (!fs.existsSync(inputPath)) {
  console.error(`❌ File mapping tidak ditemukan: ${inputPath}`);
  process.exit(1);
}

const outputPath = path.resolve(
  positional[1] ||
    path.join(path.dirname(inputPath), `${path.basename(inputPath, path.extname(inputPath))}_mlo2026.pwn`)
);

const raw = fs.readFileSync(inputPath, "utf8");
const lines = raw.split(/\r?\n/);

function isStructuralModel(modelId) {
  // Common SA-MP / GTA SA structural walls, floors, doors, glass panels & gates
  if (modelId >= 19353 && modelId <= 19515) return true;
  if (modelId >= 1491 && modelId <= 1507) return true;
  return [980, 1649, 2933, 3095, 8661, 18752, 18753, 18762, 18766].includes(modelId);
}

let convertedCreateObject = 0;
let upgradedDynamic = 0;
let structureCount = 0;
let decorCount = 0;
let rgbaWarnings = 0;

const outLines = [
  "// =============================================================================",
  `// 🏗️ Auto-Upgraded to Modern 2026 open.mp MLO Standard from ${path.basename(inputPath)}`,
  "// Includes Priority Streaming, Anti-Fall Streamer_UpdateEx & NoCameraCol Support",
  "// =============================================================================",
  "#include <open.mp>",
  "#include <streamer>",
  "",
  "#if !defined MAP_PRIO_STRUCTURE",
  "    #define MAP_PRIO_STRUCTURE (10)",
  "    #define MAP_PRIO_DECOR     (0)",
  "#endif",
  ""
];

if (isInterior) {
  outLines.push(
    "stock TeleportToUpgradedMLO(playerid, Float:x, Float:y, Float:z, Float:angle, worldid, interiorid)",
    "{",
    "    SetPlayerVirtualWorld(playerid, worldid);",
    "    SetPlayerInterior(playerid, interiorid);",
    "    Streamer_UpdateEx(playerid, x, y, z, worldid, interiorid, STREAMER_TYPE_OBJECT, 600, 1);",
    "    SetPlayerPos(playerid, x, y, z + 0.15);",
    "    SetPlayerFacingAngle(playerid, angle);",
    "    SetCameraBehindPlayer(playerid);",
    "    return 1;",
    "}",
    ""
  );
}

let objIdx = 0;
for (const line of lines) {
  // Detect potential RGBA mistake on SetDynamicObjectMaterial (should be ARGB 0xAARRGGBB)
  if (/SetDynamicObjectMaterial(Text)?\s*\(/.test(line) && /0x[0-9A-Fa-f]{6}FF\b/.test(line) && !/0xFF[0-9A-Fa-f]{6}\b/.test(line)) {
    rgbaWarnings++;
    outLines.push("    // [AUDIT WARNING] SetDynamicObjectMaterial memakai ARGB (0xAARRGGBB), bukan RGBA!");
  }

  // Upgrade legacy CreateObject(model, x, y, z, rx, ry, rz[, drawDist])
  const legacyMatch = line.match(/^(\s*)(?:([A-Za-z0-9_\[\]]+)\s*=\s*)?CreateObject\s*\(([^)]+)\)\s*;/);
  if (legacyMatch) {
    const indent = legacyMatch[1];
    const lhs = legacyMatch[2];
    const params = legacyMatch[3].split(",").map((p) => p.trim());
    if (params.length >= 7) {
      const modelId = parseInt(params[0], 10);
      const isStruct = isStructuralModel(modelId);
      const prio = isStruct ? "MAP_PRIO_STRUCTURE" : "MAP_PRIO_DECOR";
      if (isStruct) structureCount++;
      else decorCount++;
      convertedCreateObject++;

      const varName = lhs || `tmpObj`;
      const decl = lhs ? `${lhs} = ` : (isInterior ? `new STREAMER_TAG_OBJECT:${varName}_${objIdx} = ` : "");
      const drawDist = params[7] || "250.0";
      outLines.push(
        `${indent}${decl}CreateDynamicObject(${params.slice(0, 7).join(", ")}, -1, -1, -1, 250.0, ${drawDist}, -1, ${prio});`
      );
      if (isInterior) {
        const ref = lhs || `${varName}_${objIdx}`;
        outLines.push(`${indent}SetDynamicObjectNoCameraCol(${ref});`);
      }
      objIdx++;
      continue;
    }
  }

  // Upgrade bare CreateDynamicObject without priority parameter (7 params only)
  const dynMatch = line.match(/^(\s*)(?:([A-Za-z0-9_\[\]]+)\s*=\s*)?CreateDynamicObject\s*\(([^)]+)\)\s*;/);
  if (dynMatch) {
    const indent = dynMatch[1];
    const lhs = dynMatch[2];
    const params = dynMatch[3].split(",").map((p) => p.trim());
    if (params.length === 7) {
      const modelId = parseInt(params[0], 10);
      const isStruct = isStructuralModel(modelId);
      const prio = isStruct ? "MAP_PRIO_STRUCTURE" : "MAP_PRIO_DECOR";
      if (isStruct) structureCount++;
      else decorCount++;
      upgradedDynamic++;

      const decl = lhs ? `${lhs} = ` : (isInterior ? `new STREAMER_TAG_OBJECT:tmpObj_${objIdx} = ` : "");
      outLines.push(
        `${indent}${decl}CreateDynamicObject(${params.join(", ")}, -1, -1, -1, 250.0, 250.0, -1, ${prio});`
      );
      if (isInterior) {
        const ref = lhs || `tmpObj_${objIdx}`;
        outLines.push(`${indent}SetDynamicObjectNoCameraCol(${ref});`);
      }
      objIdx++;
      continue;
    }
  }

  outLines.push(line);
}

fs.writeFileSync(outputPath, outLines.join("\n") + "\n", "utf8");
console.log(`✅ [SAMP MAP-UPGRADE] Selesai -> ${outputPath}`);
console.log(`   • Legacy CreateObject -> Dynamic : ${convertedCreateObject}`);
console.log(`   • DynamicObject diberi Priority  : ${upgradedDynamic}`);
console.log(`   • Klasifikasi Priority           : ${structureCount} Structure (Prio 10) | ${decorCount} Decor (Prio 0)`);
if (isInterior) {
  console.log(`   • Mode Interior MLO              : SetDynamicObjectNoCameraCol + TeleportToUpgradedMLO disuntikkan!`);
}
if (rgbaWarnings > 0) {
  console.log(`   ⚠️  Peringatan Material ARGB     : ${rgbaWarnings} baris terdeteksi potensi salah format RGBA!`);
}
