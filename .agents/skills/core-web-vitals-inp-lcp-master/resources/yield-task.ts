export async function yieldToMainThread() {
  if ('scheduler' in window && 'yield' in (window as any).scheduler) {
    await (window as any).scheduler.yield();
  } else {
    await new Promise(resolve => setTimeout(resolve, 0));
  }
}
