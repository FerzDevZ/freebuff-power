#!/usr/bin/env bash
# Quick audit checklist for Rust projects

echo "🦀 Rust Code Quality & Performance Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah semua unwrap() dan expect() diganti dengan Result/Option pattern matching?"
echo "2. [ ] Apakah cargo clippy -- -D warnings berjalan tanpa error?"
echo "3. [ ] Apakah clone() yang tidak perlu dihindari dengan borrowing (&str / &[T])?"
echo "4. [ ] Apakah Tokio tasks menggunakan tokio::select! untuk timeout dan cancellation?"
echo "---------------------------------------------------------"
echo "Status: Rust audit checklist ready."
