---
name: llm-evals-observability-2026
description: Eval-Driven LLM Engineering & AI Observability — golden evaluation datasets, deterministic code graders + calibrated LLM-as-a-Judge rubrics, RAG faithfulness & tool-call accuracy metrics, OpenTelemetry GenAI semantic traces (Langfuse/Arize Phoenix), cost/latency telemetry, and CI regression gates.
---

# Eval-Driven LLM Engineering & AI Observability (2026)

"Vibes-based prompting" breaks in production. Ship every prompt, model swap, RAG index change, or agent tool edit behind an **automated evaluation harness**.

## 1. The 3-Tier Evaluation Pyramid
1. **Tier 1 — Deterministic Code Assertions (Fast, Free, Run on Every PR):**
   - JSON Schema / Pydantic validity, exact tool name & required arguments, zero hallucinated IDs/URLs, latency ceiling, token budget, regex/PII leak checks, unit tests on generated code.
2. **Tier 2 — Calibrated LLM-as-a-Judge (Pairwise or Binary Pass/Fail Rubric):**
   - **Never ask for arbitrary 1–10 scores** (noisy & uncalibrated). Use **binary PASS/FAIL per explicit criterion** + require a 1-sentence justification BEFORE the verdict!
   - Calibrate judge against 30–50 human-labeled golden examples (`Cohen's kappa >= 0.80`).
3. **Tier 3 — Production Online Traces & User Signals:**
   - Capture implicit signals (thumbs up/down, copy/edit rate, retry/abandonment rate, escalation to human) and promote real production failures directly into the regression golden dataset!

## 2. Core Metrics by System Type
- **RAG / Search Systems:** Retrieval Recall@K, MRR, Context Precision, Faithfulness / Groundedness (zero unsupported claims), Citation Accuracy.
- **Tool-Calling Agents:** Tool Selection Precision, Argument Schema Accuracy, Trajectory Efficiency (steps vs optimal), Task Completion Rate (`pass@1` & `pass^3` consistency).

## 3. OpenTelemetry GenAI Observability
Instrument every LLM span with standard attributes: `gen_ai.system`, `gen_ai.request.model`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`, `gen_ai.usage.cache_read_tokens`, `cost_usd`, `ttft_ms`, `trace_id`, and `prompt_version` — exported cleanly to **Langfuse**, **Arize Phoenix**, or **Grafana Tempo** with PII scrubbing at the collector.
