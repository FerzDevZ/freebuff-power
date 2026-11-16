#!/usr/bin/env python3
"""
System Capacity & Back-of-the-Envelope Estimator
Calculates Read/Write QPS, Bandwidth, and Storage requirements given DAU and payload sizes.
"""

import sys

def calculate_capacity(dau: int, requests_per_user: int, avg_payload_kb: float, read_to_write_ratio: float = 10.0):
    total_daily_requests = dau * requests_per_user
    seconds_in_day = 86400
    avg_qps = total_daily_requests / seconds_in_day
    peak_qps = avg_qps * 2.5

    write_qps = avg_qps / (1.0 + read_to_write_ratio)
    read_qps = avg_qps - write_qps

    daily_storage_gb = (total_daily_requests * avg_payload_kb) / (1024 * 1024)
    bandwidth_mbps = (avg_qps * avg_payload_kb * 8) / 1024

    print("\n📊 Estimasi Kapasitas Sistem:")
    print(f"  Total Permintaan Harian : {total_daily_requests:,.0f}")
    print(f"  Rata-rata QPS           : {avg_qps:,.1f} req/s")
    print(f"  Puncak (Peak) QPS       : {peak_qps:,.1f} req/s")
    print(f"  Read QPS                : {read_qps:,.1f} req/s")
    print(f"  Write QPS               : {write_qps:,.1f} req/s")
    print(f"  Estimasi Bandwidth      : {bandwidth_mbps:,.2f} Mbps")
    print(f"  Estimasi Storage Harian : {daily_storage_gb:,.2f} GB/hari ({daily_storage_gb * 365 / 1024:,.2f} TB/tahun)")

if __name__ == "__main__":
    calculate_capacity(dau=1_000_000, requests_per_user=20, avg_payload_kb=10.0, read_to_write_ratio=10.0)
