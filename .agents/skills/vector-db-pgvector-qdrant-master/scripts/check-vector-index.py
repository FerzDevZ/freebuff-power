#!/usr/bin/env python3
"""
Vector Index Dimension & Metric Sanity Check
"""

import sys

SUPPORTED_DIMENSIONS = [384, 512, 768, 1024, 1536, 3072]

def check_vector(dim: int, metric: str):
    print(f"\n📐 Checking Vector Config: {dim}d, metric='{metric}'")
    if dim not in SUPPORTED_DIMENSIONS:
        print(f"⚠️ Warning: Non-standard embedding dimension {dim}d. Standard: {SUPPORTED_DIMENSIONS}")
    else:
        print(f"✅ Dimension {dim}d is standard for modern LLM embedding models.")

    if metric not in ["cosine", "dot_product", "euclidean"]:
        print(f"❌ Unsupported metric: {metric}")
    else:
        print(f"✅ Metric '{metric}' is supported for HNSW indexing.")

if __name__ == "__main__":
    d = int(sys.argv[1]) if len(sys.argv) > 1 else 1536
    m = sys.argv[2] if len(sys.argv) > 2 else "cosine"
    check_vector(d, m)
