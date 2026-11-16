#!/usr/bin/env bash
# Quick audit checklist for Dockerfiles

echo "🐳 Docker Container Security & Optimization Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah multi-stage build digunakan untuk memisahkan compiler SDK dari runtime?"
echo "2. [ ] Apakah container berjalan sebagai non-root user (USER nonroot)?"
echo "3. [ ] Apakah dependency manifests di-COPY sebelum kode sumber untuk caching layer?"
echo "4. [ ] Apakah .dockerignore menyaring .git, node_modules, dan file .env?"
echo "---------------------------------------------------------"
echo "Status: Docker audit checklist ready."
