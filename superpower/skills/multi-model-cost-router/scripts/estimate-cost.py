#!/usr/bin/env python3
"""
Token Cost Estimator
Compares estimated invocation costs across Tier 1, Tier 2, and Tier 3 models.
"""

import sys

def estimate(in_tokens: int, out_tokens: int):
    # Pricing per 1M tokens
    t1_in, t1_out = 3.00, 15.00
    t2_in, t2_out = 0.25, 1.00
    t3_in, t3_out = 0.075, 0.30

    c1 = (in_tokens * t1_in + out_tokens * t1_out) / 1_000_000
    c2 = (in_tokens * t2_in + out_tokens * t2_out) / 1_000_000
    c3 = (in_tokens * t3_in + out_tokens * t3_out) / 1_000_000

    print(f"\n📊 Token Cost Comparison ({in_tokens:,} Input, {out_tokens:,} Output tokens):")
    print(f"  Tier 1 (Frontier / Claude 3.5 / Grok) : ${c1:.5f}")
    print(f"  Tier 2 (Coder / Qwen / DeepSeek)     : ${c2:.5f} ({c1/c2:.1f}x cheaper than Tier 1)")
    print(f"  Tier 3 (Fast Flash / Llama 8B)        : ${c3:.5f} ({c1/c3:.1f}x cheaper than Tier 1)")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        estimate(10_000, 2_000)
    else:
        estimate(int(sys.argv[1]), int(sys.argv[2]))
