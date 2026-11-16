#!/usr/bin/env bash
# Quick audit checklist for React & Next.js production builds

echo "⚛️ React & Next.js Best Practice Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah semua data mutations menggunakan Server Actions atau Route Handlers terproteksi?"
echo "2. [ ] Apakah komponen root page bebas dari directive 'use client'?"
echo "3. [ ] Apakah image rendering menggunakan next/image dengan properti aspect ratio?"
echo "4. [ ] Apakah state global client (Zustand/Context) di-lazyload bila hanya dibutuhkan di modal?"
echo "---------------------------------------------------------"
echo "Status: React/Next.js audit checklist ready."
