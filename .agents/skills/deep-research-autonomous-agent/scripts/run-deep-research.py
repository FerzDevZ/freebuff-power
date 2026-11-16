#!/usr/bin/env python3
"""
Deep Research Query Decomposer
Generates structured sub-queries across distinct search axes for comprehensive coverage.
"""

import sys

def decompose_query(topic: str):
    print(f"\n🔬 Decomposing Research Topic: '{topic}'")
    queries = [
        f"{topic} architecture best practices 2026",
        f"{topic} performance benchmarks comparison",
        f"{topic} production failure modes postmortem",
        f"{topic} vs alternatives trade-offs",
        f"{topic} RFC specification documentation"
    ]

    print("Generated Sub-Investigation Angles:")
    for idx, q in enumerate(queries, 1):
        print(f"  [{idx}] {q}")

if __name__ == "__main__":
    t = sys.argv[1] if len(sys.argv) > 1 else "Modern AI Agent Architecture"
    decompose_query(t)
