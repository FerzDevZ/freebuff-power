// 2-Hop Knowledge Neighborhood Query for GraphRAG Context Retrieval
MATCH (start:Entity)
WHERE start.name = $target_entity
MATCH path = (start)-[r:RELATED_TO*1..2]-(neighbor:Entity)
RETURN 
    start.name AS entity,
    [n IN nodes(path) | n.name] AS connected_nodes,
    [rel IN relationships(path) | type(rel)] AS relationships
LIMIT 25;
