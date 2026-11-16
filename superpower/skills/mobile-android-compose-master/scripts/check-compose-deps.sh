#!/usr/bin/env bash
# Quick audit checklist for Android Jetpack Compose projects

echo "🤖 Native Android Jetpack Compose Quality Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah Composable bersifat stateless dan mengikuti Unidirectional Data Flow (UDF)?"
echo "2. [ ] Apakah LazyColumn/LazyRow menyertakan key parameter unik untuk stabilitas re-komposisi?"
echo "3. [ ] Apakah StateFlow diexpose dengan SharingStarted.WhileSubscribed(5000)?"
echo "4. [ ] Apakah dependency injection menggunakan Hilt / Koin secara konsisten?"
echo "---------------------------------------------------------"
echo "Status: Jetpack Compose audit checklist ready."
