// Serve build/web (SPA fallback), launch headless Chrome with CDP, optionally
// click coordinates (to navigate the canvas-rendered Flutter UI), screenshot.
//
// Usage: node nav_shoot.js <out.png> <winH> <bootMs> [clicks]
//   clicks = "x,y,waitMs;x,y,waitMs;..."  (CSS px, applied in order)
const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const ROOT = 'C:/Users/msi/StudioProjects/anwarsajadia/build/web';
const OUT = process.argv[2] || 'C:/Users/msi/StudioProjects/anwarsajadia/.figma2/nav.png';
const WIN_H = parseInt(process.argv[3] || '932', 10);
const BOOT_MS = parseInt(process.argv[4] || '12000', 10);
const CLICKS = (process.argv[5] || '').split(';').filter(Boolean).map(s => {
  const [x, y, w] = s.split(',').map(Number);
  return { x, y, w: w || 2500 };
});
const PORT = 8732;
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json',
  '.png': 'image/png', '.svg': 'image/svg+xml', '.css': 'text/css', '.wasm': 'application/wasm',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.bin': 'application/octet-stream' };

const sleep = ms => new Promise(r => setTimeout(r, ms));

const server = http.createServer((req, res) => {
  let rel = decodeURIComponent(req.url.split('?')[0]).replace(/^\/+/, '');
  let full = path.join(ROOT, rel);
  if (!rel || !fs.existsSync(full) || fs.statSync(full).isDirectory()) full = path.join(ROOT, 'index.html');
  fs.readFile(full, (e, data) => {
    if (e) { res.writeHead(404); res.end('nf'); return; }
    res.writeHead(200, { 'Content-Type': MIME[path.extname(full)] || 'application/octet-stream' });
    res.end(data);
  });
});

let cdpId = 0;
function cdp(ws, method, params = {}) {
  return new Promise(resolve => {
    const id = ++cdpId;
    const onMsg = ev => {
      const m = JSON.parse(ev.data);
      if (m.id === id) { ws.removeEventListener('message', onMsg); resolve(m.result); }
    };
    ws.addEventListener('message', onMsg);
    ws.send(JSON.stringify({ id, method, params }));
  });
}

async function click(ws, x, y) {
  await cdp(ws, 'Input.dispatchMouseEvent', { type: 'mouseMoved', x, y, buttons: 0 });
  await sleep(120);
  await cdp(ws, 'Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', buttons: 1, clickCount: 1 });
  await sleep(80);
  await cdp(ws, 'Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', buttons: 0, clickCount: 1 });
}

(async () => {
  await new Promise(r => server.listen(PORT, '127.0.0.1', r));
  const prof = 'C:/Users/msi/StudioProjects/anwarsajadia/.figma2/_navprof';
  const chrome = spawn(CHROME, ['--headless=new', '--disable-gpu', '--no-sandbox',
    '--use-gl=angle', '--use-angle=swiftshader', '--hide-scrollbars',
    '--force-device-scale-factor=2', `--window-size=430,${WIN_H}`,
    '--remote-debugging-port=9333', `--user-data-dir=${prof}`, 'about:blank']);
  await sleep(2500);
  // discover ws endpoint
  const list = await new Promise((resolve, reject) => {
    http.get('http://127.0.0.1:9333/json', r => {
      let d = ''; r.on('data', c => d += c); r.on('end', () => resolve(JSON.parse(d)));
    }).on('error', reject);
  });
  const page = list.find(t => t.type === 'page') || list[0];
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise(r => ws.addEventListener('open', r, { once: true }));
  await cdp(ws, 'Page.enable');
  let route = process.argv[6] || '';
  if (route && !route.startsWith('/')) route = '/' + route; // avoid git-bash path mangling
  const url = route
    ? `http://127.0.0.1:${PORT}/?shoot=${encodeURIComponent(route)}`
    : `http://127.0.0.1:${PORT}/`;
  await cdp(ws, 'Page.navigate', { url });
  await sleep(BOOT_MS);
  for (const c of CLICKS) { await click(ws, c.x, c.y); await sleep(c.w); }
  const { data } = await cdp(ws, 'Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(OUT, Buffer.from(data, 'base64'));
  console.log('saved', OUT, fs.statSync(OUT).size, 'bytes');
  ws.close(); chrome.kill(); server.close();
  process.exit(0);
})().catch(e => { console.error('ERR', e); process.exit(1); });
