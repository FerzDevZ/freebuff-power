#!/usr/bin/env bash
# Quick audit checklist for Kubernetes manifests

echo "☸️ Kubernetes Manifest Production Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah semua kontainer memiliki requests dan limits (CPU & Memory)?"
echo "2. [ ] Apakah livenessProbe dan readinessProbe terpasang?"
echo "3. [ ] Apakah runAsNonRoot: true dan readOnlyRootFilesystem: true aktif?"
echo "4. [ ] Apakah rollingUpdate strategy (maxSurge, maxUnavailable) terkonfigurasi?"
echo "---------------------------------------------------------"
echo "Status: Kubernetes audit checklist ready."
