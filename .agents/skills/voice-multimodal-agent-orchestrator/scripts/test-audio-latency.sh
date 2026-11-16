#!/usr/bin/env bash
# Quick audit checklist for real-time voice and multimodal pipelines

echo "🎙️ Voice & Multimodal Agent Quality Audit:"
echo "---------------------------------------------------------"
echo "1. [ ] Apakah total latensi voice-to-voice di bawah 500ms?"
echo "2. [ ] Apakah fitur barge-in (interupsi user) aktif dan memotong audio output instan?"
echo "3. [ ] Apakah LLM mentransfer token per kalimat (bukan per seluruh respons) ke TTS?"
echo "4. [ ] Apakah gambar multimodal dikompresi sebelum dikirim ke vision model?"
echo "---------------------------------------------------------"
echo "Status: Voice agent audit checklist ready."
