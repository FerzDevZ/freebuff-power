export function triggerTactileHaptic() {
  if ('vibrate' in navigator) navigator.vibrate(12);
}
