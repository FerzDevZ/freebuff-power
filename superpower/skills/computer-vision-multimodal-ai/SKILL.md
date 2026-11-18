---
name: computer-vision-multimodal-ai
description: Production Computer Vision, OCR & Multimodal AI Engineering — RT-DETR/YOLO object detection, SAM2 segmentation, Vision-Language Models (VLM) for structured document extraction, Faster-Whisper/WebRTC real-time voice pipelines, OpenCV preprocessing, and ONNX Runtime/TensorRT INT8 edge deployment.
---

# Computer Vision, Document OCR & Multimodal AI Engineering (2026)

## 1. Choosing the Right Architecture
| Task | Best 2026 Approach | Avoid |
|---|---|---|
| **Real-Time Object Detection / Tracking** | **RT-DETR / YOLO11 + ByteTrack** exported to **TensorRT FP16/INT8** | Running a slow VLM frame-by-frame at 30 FPS |
| **Zero-Shot / Promptable Segmentation** | **SAM 2** (image + video mask propagation) | Training custom U-Net from scratch when zero-shot suffices |
| **Complex Invoices / KTP / Tables / Receipts** | **VLM Structured JSON Extraction** (or PaddleOCR/Surya + LLM schema normalizer) with Zod/Pydantic validation | Fragile coordinate-based regex over raw Tesseract dumps |
| **Real-Time Speech / Voice AI** | **Silero VAD -> Faster-Whisper (CTranslate2) -> Streaming LLM -> Kokoro/Cartesia/ElevenLabs TTS** over WebRTC | High-latency full-utterance REST polling |

## 2. Production Vision & Edge Invariants
- **Strict Color-Space Hygiene:** OpenCV loads **BGR**; PyTorch/PIL/ONNX expect **RGB** (`cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)`). Always unit-test preprocessing normalization (`mean/std`, aspect-preserving letterbox padding, and exact inverse bounding-box coordinate un-letterboxing!).
- **Decoupled Async Video Pipelines:** Run frame capture, GPU batch inference, and downstream encoding/alerting in separate bounded queues (`maxsize=4`, drop oldest frame on backpressure) so latency stays bounded instead of spiraling into OOM.
- **Edge Quantization Validation:** When quantizing FP32 -> FP16 / INT8 (TensorRT / ONNX Runtime), use a representative 500-image calibration set and verify mAP@50 drop is `< 1.0%` before shipping.
