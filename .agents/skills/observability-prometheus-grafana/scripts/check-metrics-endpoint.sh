#!/usr/bin/env bash
# Quick audit checklist for observability instrumentation

echo "📊 Observability & Prometheus Metrics Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah endpoint /metrics tersedia dan mengekspos format teks Prometheus?"
echo "2. [ ] Apakah metrik RED (Rate, Errors, Duration) diimplementasikan pada HTTP/gRPC handlers?"
echo "3. [ ] Apakah trace_id dan span_id diinjeksikan pada structured application logs?"
echo "4. [ ] Apakah histogram latency memiliki bucket boundary yang sesuai (misal: 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5)?"
echo "---------------------------------------------------------"
echo "Status: Observability audit checklist ready."
