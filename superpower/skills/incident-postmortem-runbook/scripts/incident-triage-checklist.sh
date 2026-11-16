#!/usr/bin/env bash
# Quick checklist during live production outages

echo "🚨 Production Incident Triage & Mitigation Checklist:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah Incident Commander telah ditunjuk dan War Room dibuka?"
echo "2. [ ] Apakah mitigasi tercepat (Rollback release / Traffic drain / Scale pods) telah diambil?"
echo "3. [ ] Apakah status page internal / eksternal telah diperbarui untuk pengguna?"
echo "4. [ ] Apakah timeline kejadian dicatat secara real-time (UTC)?"
echo "5. [ ] Apakah postmortem terjadwal dalam kurun waktu 48 jam setelah resolusi?"
echo "---------------------------------------------------------"
echo "Status: SRE Incident response checklist ready."
