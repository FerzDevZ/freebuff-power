#!/usr/bin/env bash
# Quick audit checklist for GitHub Actions CI/CD workflows

echo "🐙 GitHub Actions Workflow Security & Performance Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah top-level 'permissions:' dibatasi secara eksplisit (least privilege)?"
echo "2. [ ] Apakah package manager cache (npm/pip/cargo/go) diaktifkan?"
echo "3. [ ] Apakah cloud deployment menggunakan OIDC (bukan static access keys)?"
echo "4. [ ] Apakah timeout-minutes disetel pada setiap job untuk mencegah hanging runner?"
echo "---------------------------------------------------------"
echo "Status: GitHub Actions audit checklist ready."
