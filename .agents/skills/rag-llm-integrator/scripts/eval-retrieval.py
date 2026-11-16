#!/usr/bin/env python3
"""
RAG Retrieval Evaluator
Calculates Mean Reciprocal Rank (MRR) and Hit Rate @ K from retrieval test cases.
"""

import sys
import json

def evaluate_retrieval(test_cases):
    hits_at_k = {1: 0, 3: 0, 5: 0}
    reciprocal_ranks = []

    for tc in test_cases:
        expected = tc["expected_id"]
        retrieved = tc["retrieved_ids"]

        # Hit rate
        for k in hits_at_k.keys():
            if expected in retrieved[:k]:
                hits_at_k[k] += 1

        # MRR
        if expected in retrieved:
            rank = retrieved.index(expected) + 1
            reciprocal_ranks.append(1.0 / rank)
        else:
            reciprocal_ranks.append(0.0)

    total = len(test_cases)
    mrr = sum(reciprocal_ranks) / total if total else 0

    print(f"📊 Evaluasi Hasil Retrieval ({total} test queries):")
    print(f"  MRR (Mean Reciprocal Rank): {mrr:.4f}")
    for k, hits in hits_at_k.items():
        print(f"  Hit Rate @ {k}: {hits / total * 100:.1f}%")

if __name__ == "__main__":
    sample_tests = [
        {"expected_id": "doc_1", "retrieved_ids": ["doc_1", "doc_4", "doc_5"]},
        {"expected_id": "doc_2", "retrieved_ids": ["doc_9", "doc_2", "doc_3"]},
        {"expected_id": "doc_3", "retrieved_ids": ["doc_8", "doc_7", "doc_6", "doc_3"]},
    ]
    evaluate_retrieval(sample_tests)
