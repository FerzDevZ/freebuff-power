-- Production ClickHouse Analytical Event Table DDL
CREATE TABLE IF NOT EXISTS event_telemetry
(
    tenant_id UInt32,
    event_type LowCardinality(String),
    user_id UUID,
    timestamp DateTime64(3, 'UTC'),
    payload JSON,
    duration_ms Float32
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (tenant_id, event_type, timestamp)
SETTINGS index_granularity = 8192;
