#!/usr/bin/env bash
# Quick audit checklist for Kafka producers, consumers, and topic partitions

echo "📨 Apache Kafka Reliability & Performance Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah producer mengaktifkan acks=all dan idempotence=true?"
echo "2. [ ] Apakah partition key digunakan secara konsisten untuk menjamin urutan data per entitas?"
echo "3. [ ] Apakah consumer dilengkapi dengan retry backoff dan Dead Letter Queue (DLQ)?"
echo "4. [ ] Apakah kompresi pesan (snappy/zstd) diaktifkan untuk efisiensi bandwidth?"
echo "---------------------------------------------------------"
echo "Status: Kafka audit checklist ready."
