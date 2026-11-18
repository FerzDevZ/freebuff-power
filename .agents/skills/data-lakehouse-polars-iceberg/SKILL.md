---
name: data-lakehouse-polars-iceberg
description: Modern 2026 Data Engineering & Lakehouse Architecture — Polars LazyFrame pipelines replacing slow Pandas, DuckDB in-process OLAP, Apache Iceberg + Parquet partitioning & compaction, dbt incremental SQL models, Kafka/Redpanda event streaming, ClickHouse real-time analytics, and automated Data Contracts.
---

# Modern 2026 Data Engineering & Lakehouse Architecture

## 1. The Modern Single-Node & Lakehouse Stack
Don't spin up an expensive 10-node Spark cluster for 50GB of data!
- **Under 500GB Analytics / ETL:** **Polars (`pl.scan_parquet(...)` LazyFrame)** + **DuckDB** on local NVMe or S3/R2 Parquet runs 10x–50x faster than Pandas at 1/10th the memory and cloud cost.
- **Open Lakehouse Storage:** Store canonical tables in **Apache Iceberg** (ACID snapshots, schema evolution, partition evolution, time-travel rollback) over compressed **ZSTD Parquet** files (`128MB–512MB` target file size; run scheduled compaction to kill the small-files problem).
- **Real-Time User-Facing Analytics:** Stream events via **Kafka / Redpanda** -> **ClickHouse** (`ReplacingMergeTree` / materialized views) for sub-50ms dashboard aggregations over billions of rows.

## 2. Medallion Architecture & Idempotent Pipelines
```text
[Bronze: Raw Immutable Append] -> [Silver: Deduplicated, Typed, Validated] -> [Gold: Business Aggregates & ML Features]
```
- **Idempotency Law:** Re-running any backfill or batch job for date partition `2026-11-18` MUST produce the exact same rows (use `MERGE` / atomic partition overwrite — NEVER blind `INSERT APPEND`!).
- **Data Contracts at Ingestion:** Enforce strict schema, non-null primary keys, freshness SLAs, and row-count anomaly checks (`dbt tests`, `Pandera`, or `Soda`) at the Bronze->Silver boundary; route malformed records to a Dead-Letter Queue (DLQ) with full error context instead of silently dropping data.
