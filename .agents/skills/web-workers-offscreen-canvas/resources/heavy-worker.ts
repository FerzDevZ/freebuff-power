self.onmessage = (e: MessageEvent<ArrayBuffer>) => {
  // Process in background worker thread
  self.postMessage({ status: 'done' });
};
