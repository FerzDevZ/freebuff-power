#!/usr/bin/env bash
# Quick audit checklist for Go microservices

echo "🐹 Golang Concurrency & Code Quality Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah semua I/O calls menerima dan meneruskan context.Context?"
echo "2. [ ] Apakah goroutines memiliki penanganan pembatalan (select dengan ctx.Done())?"
echo "3. [ ] Apakah kode diuji dengan flag race detector (go test -race ./...)?"
echo "4. [ ] Apakah error nil checking dilakukan secara eksplisit tanpa panic?"
echo "---------------------------------------------------------"
echo "Status: Go audit checklist ready."
