/* Mon_77 Guard — عمل دون إنترنت */
const CACHE = "m77-v17";
const CORE = ["./", "./index.html", "./manifest.json", "./icon.png", "./icon-192.png", "./icon-512.png", "./icon-maskable-512.png"];
const CDN = [
  "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4",
  "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
];

async function precacheCdn(c) {
  for (const u of CDN) {
    try {
      const r = await fetch(u, { mode: "cors" });
      if (!r.ok) continue;
      await c.put(u, r.clone());
      if (u.endsWith(".css")) {
        const css = await r.text();
        const fonts = [...css.matchAll(/url\(([^)]+\.woff2[^)]*)\)/g)].map(m => new URL(m[1].replace(/["']/g, ""), u).href);
        await Promise.allSettled(fonts.map(f => c.add(new Request(f, { mode: "cors" }))));
      }
    } catch (e) { /* بلا إنترنت الآن: سيُخزَّن عند أول تحميل ناجح */ }
  }
}

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then(async (c) => { await c.addAll(CORE); await precacheCdn(c); }).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const isNav = req.mode === "navigate";
  const key = isNav ? "./index.html" : req;
  e.respondWith(caches.match(key, { ignoreSearch: true }).then((hit) => {
    const net = fetch(req).then((r) => {
      if (r && (r.ok || r.type === "opaque")) { const cp = r.clone(); caches.open(CACHE).then(c => c.put(key, cp)); }
      return r;
    }).catch(() => hit);
    return hit || net;
  }));
});

self.addEventListener("notificationclick", (e) => {
  e.notification.close();
  e.waitUntil(self.clients.matchAll({ type: "window" }).then(cs => cs.length ? cs[0].focus() : self.clients.openWindow("./index.html")));
});
