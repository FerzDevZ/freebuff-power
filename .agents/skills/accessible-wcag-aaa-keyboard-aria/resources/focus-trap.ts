export function trapFocus(element: HTMLElement) {
  const focusable = element.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
  // Maintain cyclical keyboard focus within modal container
}
