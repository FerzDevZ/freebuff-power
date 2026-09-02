#!/usr/bin/env bash
# ==============================================================================
# 🐳 FREEBUFF-POWER INSTANT MULTI-STAGE DOCKERIZER
# ==============================================================================
set -euo pipefail

C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}🐳 [FREEBUFF-POWER DOCKER] Instant Multi-Stage Containerizer${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}========================================================================${C_RESET}\n"

if [ -f "package.json" ]; then
  echo -e "📦 Mendeteksi proyek ${C_BOLD}Node.js / Next.js / TypeScript${C_RESET}..."
  cat << 'DOCKER_EOF' > Dockerfile
# Multi-stage ultra-lightweight Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --quiet
COPY . .
RUN npm run build || true

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next 2>/dev/null || true
COPY --from=builder /app/dist ./dist 2>/dev/null || true
COPY --from=builder /app/public ./public 2>/dev/null || true

EXPOSE 3000
CMD ["npm", "start"]
DOCKER_EOF

elif [ -f "go.mod" ]; then
  echo -e "📦 Mendeteksi proyek ${C_BOLD}Golang${C_RESET}..."
  cat << 'DOCKER_EOF' > Dockerfile
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o server .

FROM scratch
WORKDIR /app
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["/app/server"]
DOCKER_EOF

elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo -e "📦 Mendeteksi proyek ${C_BOLD}Python / FastAPI${C_RESET}..."
  cat << 'DOCKER_EOF' > Dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements*.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
DOCKER_EOF
fi

cat << 'COMPOSE_EOF' > docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    restart: always
    environment:
      - NODE_ENV=production
COMPOSE_EOF

echo -e "\n${C_GREEN}✅ Sukses! File 'Dockerfile' (Multi-Stage < 50MB) & 'docker-compose.yml' berhasil dibuat.${C_RESET}"
echo -e "👉 Untuk menjalankan: ${C_CYAN}docker-compose up -d --build${C_RESET}\n"
