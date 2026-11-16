export function sanitizeUntrustedInput(rawInput: string): string {
  return rawInput.replace(/ignore previous instructions/gi, '[REDACTED_ATTEMPT]');
}
