#!/usr/bin/env bash
# Quick audit checklist for Vue 3 and Nuxt 3 best practices

echo "🟢 Vue 3 & Nuxt 3 Project Checklist:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah semua single file component (.vue) menggunakan <script setup lang='ts'>?"
echo "2. [ ] Apakah state management global terpusat di Pinia (bukan reactive global mutable)?"
echo "3. [ ] Apakah data fetching SSR Nuxt 3 menggunakan useAsyncData / useFetch?"
echo "4. [ ] Apakah reactive destructuring menggunakan storeToRefs() untuk mempertahankan reactivity?"
echo "---------------------------------------------------------"
echo "Status: Vue 3 / Nuxt audit checklist ready."
