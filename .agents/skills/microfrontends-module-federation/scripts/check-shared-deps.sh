#!/usr/bin/env bash
# Quick audit checklist for Microfrontend Module Federation setups

echo "🧩 Microfrontend Module Federation Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah React dan React-DOM dideklarasikan sebagai singleton: true?"
echo "2. [ ] Apakah setiap remote dibungkus dengan React Error Boundary di Host app?"
echo "3. [ ] Apakah CSS diisolasi (Tailwind prefix, CSS Modules, atau Shadow DOM) untuk mencegah style leakage?"
echo "4. [ ] Apakah versi package shared kompatibel secara semver across repos?"
echo "---------------------------------------------------------"
echo "Status: Microfrontend audit checklist ready."
