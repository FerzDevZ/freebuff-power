// Production Stripe Webhook Handler with Signature Verification (Fastify / Express)
import crypto from 'crypto';

export function verifyWebhookSignature(payload: string, signatureHeader: string, secret: string): boolean {
  const parts = signatureHeader.split(',').reduce((acc, part) => {
    const [k, v] = part.split('=');
    acc[k.trim()] = v.trim();
    return acc;
  }, {} as Record<string, string>);

  const timestamp = parts['t'];
  const expectedSig = parts['v1'];
  if (!timestamp || !expectedSig) return false;

  const signedPayload = `${timestamp}.${payload}`;
  const computedSig = crypto.createHmac('sha256', secret).update(signedPayload, 'utf8').digest('hex');

  return crypto.timingSafeEqual(Buffer.from(expectedSig), Buffer.from(computedSig));
}
