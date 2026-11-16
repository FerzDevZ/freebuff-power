#!/usr/bin/env bash
# Quick audit checklist for SwiftUI and iOS application code

echo "📱 Native iOS & SwiftUI Code Quality Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah ViewModel menggunakan @Observable dan @MainActor?"
echo "2. [ ] Apakah shared mutable state dilindungi oleh Actor types?"
echo "3. [ ] Apakah asynchronous task dipicu menggunakan .task { } modifier?"
echo "4. [ ] Apakah navigasi menggunakan NavigationStack (bukan NavigationView usang)?"
echo "---------------------------------------------------------"
echo "Status: SwiftUI audit checklist ready."
