#!/usr/bin/env bash
# Quick audit checklist for GraphRAG and Neo4j Cypher queries

echo "🕸️ GraphRAG & Knowledge Graph Quality Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah entitas telah melalui proses deduplikasi / disambiguasi?"
echo "2. [ ] Apakah multi-hop traversal dibatasi maksimal 2-3 hops?"
echo "3. [ ] Apakah indeks unik dibuat pada properti entity (name / id)?"
echo "4. [ ] Apakah hybrid retrieval menggabungkan Cypher graph + Vector embeddings?"
echo "---------------------------------------------------------"
echo "Status: GraphRAG audit checklist ready."
