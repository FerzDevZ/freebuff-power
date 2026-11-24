#!/usr/bin/env bash
# ==============================================================================
# ⚡ FREEBUFF-POWER INSTANT PROJECT SCAFFOLDER
# ==============================================================================
set -euo pipefail

PRESET="${1:-saas}"
NAME="${2:-my-app}"

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}⚡ [FREEBUFF-POWER NEW] Instant Project Scaffolder${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

mkdir -p "$NAME"
cd "$NAME"

case "$PRESET" in
  saas|nextjs|web)
    echo -e "🚀 Menyiapkan preset ${C_BOLD}Modern Fullstack SaaS (Next.js 15 + Tailwind + TypeScript)${C_RESET}..."
    cat << 'PACKAGE_EOF' > package.json
{
  "name": "saas-starter",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "^15.1.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "@types/react": "^19.0.0",
    "tailwindcss": "^4.0.0"
  }
}
PACKAGE_EOF
    ;;

  flutter|mobile)
    echo -e "🚀 Menyiapkan preset ${C_BOLD}Flutter Clean Architecture (BLoC + Riverpod)${C_RESET}..."
    mkdir -p lib/domain lib/data lib/presentation
    cat << 'FLUTTER_EOF' > pubspec.yaml
name: flutter_app
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.0
  flutter_riverpod: ^2.5.0
FLUTTER_EOF
    ;;

  microservice|go|api)
    echo -e "🚀 Menyiapkan preset ${C_BOLD}Go Microservice (Gin + PostgreSQL + Docker)${C_RESET}..."
    cat << 'GO_EOF' > main.go
package main

import (
	"net/http"
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "UP", "engine": "Freebuff Superpower"})
	})
	r.Run(":8080")
}
GO_EOF
    ;;

  openmp|omp|samp-openmp)
    echo -e "🚀 Menyiapkan preset ${C_BOLD}Modern open.mp Gamemode (YSI 5 + MySQL R41-4 + Bcrypt)${C_RESET}..."
    mkdir -p gamemodes/modules/core gamemodes/modules/player gamemodes/modules/vehicle scriptfiles .github/workflows
    
    cat << 'OMP_JSON' > config.json
{
  "$schema": "https://open.mp/schemas/config.json",
  "name": "open.mp Modern Server",
  "password": "",
  "max_players": 100,
  "port": 7777,
  "rcon": {
    "password": "ChangeThisPassword123!"
  },
  "pawn": {
    "main_scripts": ["main"],
    "legacy_plugins": ["crashdetect", "sscanf", "mysql", "streamer"]
  },
  "logging": {
    "log_chat": true,
    "log_queries": false
  }
}
OMP_JSON

    cat << 'PAWN_JSON' > pawn.json
{
  "user": "Developer",
  "repo": "openmp-gamemode",
  "entry": "gamemodes/main.pwn",
  "output": "gamemodes/main.amx",
  "dependencies": [
    "openmultiplayer/omp-stdlib",
    "Pawn-Lang/YSI-Includes",
    "samp-incognito/samp-streamer-plugin",
    "pawn-lang/sscanf",
    "pawn-lang/crashdetect"
  ],
  "builds": [
    {
      "compiler": { "version": "3.10.10" },
      "args": ["-d3", "-;+", "-(+", "-Z"]
    }
  ]
}
PAWN_JSON

    cat << 'MAIN_PWN' > gamemodes/main.pwn
#define FILTERSCRIPT
#include <open.mp>
#include <streamer>
#include <sscanf2>
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_commands>
#include <YSI_Data\y_iterate>

#include "modules/core/database.inc"
#include "modules/player/auth.inc"

main() {
    print("==================================================");
    print("   Modern open.mp Modular Gamemode Initialized!   ");
    print("   Powered by freebuff-power & freepi-power       ");
    print("==================================================");
}

public OnGameModeInit() {
    SetGameModeText("open.mp v1.2");
    AddPlayerClass(0, 1958.33, 1343.12, 15.36, 269.15, 0, 0, 0, 0, 0, 0);
    return 1;
}
MAIN_PWN

    cat << 'DB_INC' > gamemodes/modules/core/database.inc
#if defined _INC_core_database
    #endinput
#endif
#define _INC_core_database

#include <YSI_Coding\y_hooks>

hook OnGameModeInit() {
    print("[Database] MySQL Connection Module Initialized.");
    return 1;
}
DB_INC

    cat << 'AUTH_INC' > gamemodes/modules/player/auth.inc
#if defined _INC_player_auth
    #endinput
#endif
#define _INC_player_auth

#include <YSI_Coding\y_hooks>

hook OnPlayerConnect(playerid) {
    SendClientMessage(playerid, 0x00FF88FF, "Selamat datang di Server open.mp!");
    return 1;
}

YCMD:help(playerid, params[], help) {
    if (help) return SendClientMessage(playerid, -1, "Perintah bantuan.");
    SendClientMessage(playerid, 0xFFFF00FF, "Gunakan /cmds untuk melihat daftar perintah.");
    return 1;
}
AUTH_INC

    cat << 'CI_YML' > .github/workflows/compile.yml
name: open.mp Compile Check
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install sampctl
        run: |
          curl -sL https://raw.githubusercontent.com/Southclaws/sampctl/master/install.sh | sh
          sudo mv bin/sampctl /usr/local/bin/
      - name: Build Gamemode
        run: sampctl package ensure && sampctl package compile
CI_YML
    ;;

  samp-rp|samp-roleplay|roleplay)
    echo -e "🚀 Menyiapkan preset ${C_BOLD}GTA SA-MP / open.mp Heavy Roleplay Gamemode${C_RESET}..."
    mkdir -p gamemodes/modules/core gamemodes/modules/player gamemodes/modules/vehicle gamemodes/modules/faction gamemodes/modules/economy scriptfiles
    
    cat << 'RP_CFG' > server.cfg
echo Executing Server Config...
lanmode 0
rcon_password RoleplayAdminPass2026!
maxplayers 150
port 7777
hostname "San Andreas Roleplay | play.roleplay.id"
gamemode0 main 1
filterscripts anticheat
plugins crashdetect sscanf mysql streamer
stream_distance 250.0
stream_rate 1000
logtimeformat [%H:%M:%S]
RP_CFG

    cat << 'RP_MAIN' > gamemodes/main.pwn
#include <open.mp>
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_commands>
#include <YSI_Data\y_iterate>
#include <YSI_Data\y_bit>

#define MAX_FACTIONS 20

enum E_PLAYER_DATA {
    bool:pLoggedIn,
    pDBID,
    pCash,
    pBank,
    pFactionID
};
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];

main() {
    print(">>> San Andreas Roleplay Gamemode Started <<<");
}

public OnGameModeInit() {
    SetGameModeText("SARP v1.0 Roleplay");
    return 1;
}

YCMD:stats(playerid, params[], help) {
    new msg[128];
    format(msg, sizeof(msg), "[STATS] Uang Tunai: $%d | Saldo Bank: $%d", PlayerData[playerid][pCash], PlayerData[playerid][pBank]);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}
RP_MAIN
    ;;
esac

# Injeksi Superpower otomatis ke folder baru
echo -e "\n🧰 Menyuntikkan 126 Sub-Agents & 655 Modular Skills..."
freebuff-power init .

echo -e "\n${C_GREEN}${C_BOLD}🎉 PROYEK '$NAME' BERHASIL DISCAFFOLD!${C_RESET}"
echo -e "👉 Masuk ke folder & mulai koding:"
echo -e "   \033[0;36mcd $NAME && freebuff-power start\033[0m\n"
