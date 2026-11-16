CREATE TABLE server_metrics (
    recorded_at TIMESTAMPTZ NOT NULL,
    cpu_usage FLOAT NOT NULL
) PARTITION BY RANGE (recorded_at);
