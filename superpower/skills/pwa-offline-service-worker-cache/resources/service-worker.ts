import { registerRoute } from 'workbox-routing';
import { StaleWhileRevalidate, CacheFirst } from 'workbox-strategies';

registerRoute(({ request }) => request.destination === 'image', new CacheFirst({ cacheName: 'images' }));
