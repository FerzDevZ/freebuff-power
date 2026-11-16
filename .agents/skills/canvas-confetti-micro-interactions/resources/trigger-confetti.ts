import confetti from 'canvas-confetti';

export function triggerSuccessConfetti() {
  confetti({
    particleCount: 100,
    spread: 70,
    origin: { y: 0.6 },
    colors: ['#6366f1', '#ec4899', '#10b981']
  });
}
