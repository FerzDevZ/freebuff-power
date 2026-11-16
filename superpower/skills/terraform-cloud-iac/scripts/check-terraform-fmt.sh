#!/usr/bin/env bash
# Quick audit checklist for Terraform modules

echo "🌍 Terraform IaC Quality & Security Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah remote state terenkripsi dengan DynamoDB/GCS locking diaktifkan?"
echo "2. [ ] Apakah provider dan module versions dipin secara deterministik?"
echo "3. [ ] Apakah public access terblokir pada resource storage (S3/Cloud Storage)?"
echo "4. [ ] Apakah terraform fmt dan terraform validate berjalan sukses?"
echo "---------------------------------------------------------"
echo "Status: Terraform audit checklist ready."
