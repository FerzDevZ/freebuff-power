#!/usr/bin/env bash
# Quick audit checklist for Temporal workflows determinism

echo "⏳ Temporal Workflow Determinism & Reliability Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah semua I/O eksternal (DB, HTTP) dijalankan di dalam Activity (bukan Workflow)?"
echo "2. [ ] Apakah fungsi Workflow bebas dari Math.random() dan Date.now() langsung?"
echo "3. [ ] Apakah Saga compensation rollback disiapkan untuk setiap mutasi status?"
echo "4. [ ] Apakah semua Activity menerapkan parameter timeout (startToCloseTimeout)?"
echo "---------------------------------------------------------"
echo "Status: Temporal workflow audit checklist ready."
