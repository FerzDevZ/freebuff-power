-- Production Vector Search Query with Metadata Filtering (PostgreSQL)
SELECT 
    id,
    content,
    metadata,
    1 - (embedding <=> $1) AS cosine_similarity
FROM 
    document_embeddings
WHERE 
    metadata->>'tenant_id' = $2
ORDER BY 
    embedding <=> $1
LIMIT 10;
