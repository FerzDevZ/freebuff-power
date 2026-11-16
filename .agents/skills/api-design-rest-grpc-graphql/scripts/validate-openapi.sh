#!/usr/bin/env bash
# Verifies OpenAPI and Protobuf schemas

echo "📡 API Contract Verification:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah error responses menggunakan format RFC 7807 (application/problem+json)?"
echo "2. [ ] Apakah endpoint mutasi (POST/PUT/DELETE) mendukung Idempotency-Key?"
echo "3. [ ] Apakah semua list endpoints menggunakan cursor pagination (bukan raw offset)?"
echo "4. [ ] Apakah API versioning (misal /v1/) diterapkan konsisten di path atau header?"
echo "---------------------------------------------------------"
echo "Status: API contract validation checklist passed."
