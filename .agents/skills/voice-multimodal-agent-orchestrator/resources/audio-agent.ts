// Real-Time Audio Agent Pipeline with Sentence-by-Sentence TTS Streaming (TypeScript)
export interface VoiceAgentConfig {
  sampleRate: number;
  vadSensitivity: number;
  sttEndpoint: string;
  ttsVoiceId: string;
}

export class StreamingVoiceAgent {
  constructor(private readonly config: VoiceAgentConfig) {}

  async onSpeechDetected(audioChunk: ArrayBuffer): Promise<void> {
    // Stream audio buffer to STT WebSocket
  }

  async onSentenceCompleted(sentenceText: string): Promise<void> {
    // Immediately forward complete sentence to streaming TTS WebSocket
  }

  handleBargeIn(): void {
    // Cancel in-flight audio playback queue instantly
  }
}
