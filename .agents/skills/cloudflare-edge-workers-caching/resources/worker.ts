export default {
  async fetch(request: Request, env: any): Promise<Response> {
    const cache = caches.default;
    let response = await cache.match(request);
    if (!response) {
      response = new Response('Hello from Cloudflare Edge Worker!');
    }
    return response;
  }
};
