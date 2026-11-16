"""
Hybrid Search & RRF (Reciprocal Rank Fusion) Reference Implementation
Combines Dense Vector Ranking and Sparse Keyword Ranking
"""

from typing import List, Dict

def reciprocal_rank_fusion(dense_results: List[Dict], sparse_results: List[Dict], k: int = 60) -> List[Dict]:
    """
    RRF Score = sum(1 / (k + rank_i))
    """
    scores = {}
    doc_map = {}

    for rank, doc in enumerate(dense_results):
        doc_id = doc["id"]
        doc_map[doc_id] = doc
        scores[doc_id] = scores.get(doc_id, 0.0) + (1.0 / (k + rank + 1))

    for rank, doc in enumerate(sparse_results):
        doc_id = doc["id"]
        doc_map[doc_id] = doc
        scores[doc_id] = scores.get(doc_id, 0.0) + (1.0 / (k + rank + 1))

    ranked_doc_ids = sorted(scores.keys(), key=lambda x: scores[x], reverse=True)
    return [{**doc_map[doc_id], "rrf_score": scores[doc_id]} for doc_id in ranked_doc_ids]
