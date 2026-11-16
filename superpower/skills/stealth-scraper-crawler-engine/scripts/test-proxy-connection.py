#!/usr/bin/env python3
"""
Proxy Connection and Latency Tester
"""

import sys
import time
import urllib.request

def test_connection(url: str = "https://httpbin.org/ip"):
    print(f"📡 Testing connection to {url} ...")
    start = time.time()
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = resp.read().decode("utf-8")
            elapsed = (time.time() - start) * 1000
            print(f"✅ Connection Successful ({elapsed:.1f}ms):")
            print(f"  Response: {data.strip()}")
    except Exception as e:
        print(f"❌ Connection Failed: {e}")

if __name__ == "__main__":
    test_connection()
