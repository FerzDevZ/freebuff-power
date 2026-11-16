#!/usr/bin/env bash
# Quick audit checklist for Flutter & React Native mobile projects

echo "📱 Mobile App Architecture & Performance Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah UI membaca dari local cache database (offline-first)?"
echo "2. [ ] Apakah mutasi offline disimpan dalam antrean persisten dengan retry backoff?"
echo "3. [ ] Apakah list panjang menggunakan virtualized rendering (FlashList / ListView.builder)?"
echo "4. [ ] Apakah deep links dikonfigurasi dengan skema verifikasi domain resmi?"
echo "---------------------------------------------------------"
echo "Status: Mobile architecture checklist ready."
