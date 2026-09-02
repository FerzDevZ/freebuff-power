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
esac

# Injeksi Superpower otomatis ke folder baru
echo -e "\n🧰 Menyuntikkan 46 Sub-Agents & 1,055 Modular Skills..."
freebuff-power init .

echo -e "\n${C_GREEN}${C_BOLD}🎉 PROYEK '$NAME' BERHASIL DISCAFFOLD!${C_RESET}"
echo -e "👉 Masuk ke folder & mulai koding:"
echo -e "   \033[0;36mcd $NAME && freebuff-power start\033[0m\n"
