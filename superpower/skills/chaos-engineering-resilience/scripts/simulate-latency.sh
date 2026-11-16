#!/usr/bin/env bash
# Quick checklist and command helper for chaos resilience simulations

echo "💥 Chaos Engineering & Fault Injection Checklist:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah steady-state metrics (latency & error rate) terdefinisi dengan jelas?"
echo "2. [ ] Apakah blast radius dibatasi dan abort conditions (kill switch) aktif?"
echo "3. [ ] Apakah circuit breaker (Resilience4j / Polly / Envoy) terkonfigurasi?"
echo "4. [ ] Apakah fallback response terbukti ditampilkan saat upstream down?"
echo "---------------------------------------------------------"
echo "Status: Chaos resilience checklist ready."
