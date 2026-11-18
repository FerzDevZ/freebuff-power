---
name: deep-learning-pytorch-2026
description: Production PyTorch 2.x Deep Learning & LLM Post-Training Engineering — torch.compile, FSDP2/DDP distributed training, BF16/FP8 mixed precision, FlashAttention/SDPA, LoRA/QLoRA/DPO/GRPO fine-tuning with PEFT & TRL, gradient checkpointing, deterministic reproducibility, and GPU memory profiling.
---

# Production PyTorch 2.x & Modern Deep Learning (2026)

## 1. Non-Negotiable Training Invariants
1. **Reproducibility & Determinism:** Seed Python, NumPy, PyTorch CPU/CUDA (`torch.manual_seed`, `torch.cuda.manual_seed_all`), log exact git SHA + dataset hash + hyperparams to MLflow/W&B before step 0.
2. **Modern Precision & Kernels:**
   - Default to **`bfloat16`** (`torch.autocast("cuda", dtype=torch.bfloat16)`) on Ampere/Hopper/Blackwell GPUs — avoids FP16 `GradScaler` overflow instability.
   - Use **`F.scaled_dot_product_attention`** (dispatches FlashAttention-2 / cuDNN SDPA automatically).
   - Enable **`torch.compile(model, mode="reduce-overhead")`** for 1.3x–2.2x throughput after verifying eager mode numerically.
3. **Zero Silent Data Bugs:**
   - Assert tensor shapes, dtypes, `torch.isfinite(loss)` guard (abort/skip NaN steps with diagnostics), and verify train/val/test split has zero entity/group leakage.
   - Set `DataLoader(..., num_workers=..., pin_memory=True, persistent_workers=True)` to eliminate GPU starvation.

## 2. Modern LLM Post-Training (SFT, LoRA/QLoRA, DPO, GRPO)
- **QLoRA (4-bit NF4 + Double Quantization):** Target ALL linear projections (`q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj`) with `r=16..64`, `lora_alpha=2*r`, `lora_dropout=0.05`, cosine LR schedule (`warmup_ratio=0.03`), paged AdamW 8-bit.
- **Preference & Reasoning Alignment:**
  - Use **DPO / SimPO** when you have `(prompt, chosen, rejected)` preference pairs.
  - Use **GRPO (Group Relative Policy Optimization)** with deterministic verifiable reward functions (unit tests, math/JSON schema checkers) for coding/reasoning tasks without a separate critic network.
- **Distributed Scaling:** Prefer **FSDP2 (`fully_shard`)** + Activation Checkpointing for multi-GPU >7B models over legacy `DataParallel` (never use `nn.DataParallel`).

## 3. Debugging & GPU Memory Profiling Checklist
- Check `torch.cuda.memory_allocated()` vs `memory_reserved()`, capture Chrome trace via `torch.profiler.profile`, detach logged scalars (`loss.detach().item()`, NEVER accumulate live computation graphs in lists!).
- Always run a **1-batch overfit sanity test** (loss must drop near 0.0) before launching a multi-hour GPU run.
