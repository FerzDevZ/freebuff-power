// Production Nuxt 3 Custom Composable with Type-Safety
export const useDebounce = <T extends (...args: any[]) => void>(fn: T, delayMs: number) => {
  let timeoutId: ReturnType<typeof setTimeout> | null = null;

  const debouncedFn = (...args: Parameters<T>) => {
    if (timeoutId) clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      fn(...args);
    }, delayMs);
  };

  onUnmounted(() => {
    if (timeoutId) clearTimeout(timeoutId);
  });

  return debouncedFn;
};
