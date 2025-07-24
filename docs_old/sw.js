const CACHE_NAME = 'cra-soc-v1';
const OFFLINE_URLS = [
  '/',
  '/index.html',
  '/shinylive/shinylive.wasm',
  '/shinylive/r-runtime.wasm',
  // Add any files that you want to cache on the client's browser here:
  '/styles.css',
  '/about.html'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(OFFLINE_URLS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
  );
});
