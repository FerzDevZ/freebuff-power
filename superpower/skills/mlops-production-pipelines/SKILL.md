---
name: mlops-production-pipelines
description: Production MLOps & Model Serving Engineering — data contracts & versioning (DVC/LakeFS), experiment tracking (MLflow/W&B), model registry promotion gates, high-throughput inference serving (vLLM, SGLang, Triton, ONNX Runtime, TensorRT), shadow/canary rollouts, feature drift monitoring, and automated rollback.
---

# Production MLOps & High-Throughput Model Serving (2026)

A notebook model is a prototype; a production ML system is a **reproducible, versioned, observable, rollback-capable pipeline**.

## 1. End-to-End Promotion Pipeline
```text
[Versioned Data Contract] -> [Reproducible Training Run] -> [Offline Eval Gate] -> [Model Registry Staging] -> [Shadow / 5% Canary] -> [Production + Drift Alerts]
```
- **Data & Artifact Lineage:** Every model binary in the Registry MUST record `git_commit`, `dataset_snapshot_id`, `feature_schema_version`, `eval_metrics_json`, and `latency_p99_ms`.
- **Promotion Gate:** Block deployment automatically if candidate regresses on primary business metric, worst-slice subgroup metric, or p99 latency budget.

## 2. Inference Engine Selection Matrix
| Workload | Optimal Serving Engine | Key Optimizations |
|---|---|---|
| **Open-Weight LLMs (7B–70B+)** | **vLLM** or **SGLang** | PagedAttention, continuous batching, prefix caching (RadixAttention), AWQ/FP8 quantization, OpenAI-compatible API |
| **Classical / Tabular (XGBoost/LightGBM)** | **FastAPI + ONNX Runtime** | Static batching, `float32` vectorization, <5ms p99 CPU inference |
| **Vision / Audio / Embeddings** | **NVIDIA Triton / TensorRT / ONNX Runtime** | Dynamic batching, FP16/INT8 calibration, pinned GPU streams |
| **Edge / Local Privacy** | **Ollama / llama.cpp (GGUF Q4_K_M / Q6_K)** | Zero network egress, quantized KV cache |

## 3. Production Reliability & Drift Guardrails
- **Shadow Deployment First:** Mirror 10% live traffic asynchronously to the new model without exposing responses to users; compare latency, error rate, and output distribution before canary cutover.
- **Monitoring Golden Signals:** Track Input Feature Drift (PSI / KS-test), Prediction Distribution Shift, GPU utilization/KV-cache pressure, Time-to-First-Token (TTFT), Tokens/sec, and fallback trigger rate.
- **Instant Rollback:** Keep previous production model artifact warm/cached so switching traffic back takes `<10 seconds` with zero container rebuild.
