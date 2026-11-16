#!/usr/bin/env bash
# Quick audit checklist for ClickHouse schemas and queries

echo "⚡ ClickHouse Analytical Performance Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah penulisan data dilakukan secara batch (>= 10,000 rows) atau menggunakan async_insert?"
echo "2. [ ] Apakah kolom berulang menggunakan tipe LowCardinality(String)?"
echo "3. [ ] Apakah urutan kolom ORDER BY disusun dari kardinalitas terendah ke tertinggi?"
echo "4. [ ] Apakah metrik berat dihitung menggunakan Materialized Views?"
echo "---------------------------------------------------------"
echo "Status: ClickHouse audit checklist ready."
