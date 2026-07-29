// Rasterize each Figma-geometry SVG -> transparent high-res PNG via headless
// Chrome (whose SVG renderer is correct), so Flutter can use Image.asset and
// render identically on web AND device (no flutter_svg quirks).
const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const path = require('path');

const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const ROOT = 'C:/Users/msi/StudioProjects/anwarsajadia';
const SRC = ROOT + '/assets/figma_assets';
const PORT = 8801;
const SCALE = 6; // crispness
const sleep = ms => new Promise(r => setTimeout(r, ms));

const FILES = fs.readdirSync(SRC).filter(f => f.endsWith('.svg'));

const server = http.createServer((req, res) => {
  let rel = decodeURIComponent(req.url.split('?')[0]).replace(/^\/+/, '');
  let full = path.join(ROOT, rel);
  if (!fs.existsSync(full)) { res.writeHead(404); res.end(); return; }
  const ext = path.extname(full);
  const mime = ext === '.svg' ? 'image/svg+xml'
    : ext === '.html' ? 'text/html' : 'application/octet-stream';
  res.writeHead(200, { 'Content-Type': mime });
  res.end(fs.readFileSync(full));
});

function cdp(ws, method, params = {}) {
  return new Promise(r => {
    const id = Math.floor(Math.random() * 1e9);
    const f = e => {
      const m = JSON.parse(e.data);
      if (m.id === id) { ws.removeEventListener('message', f); r(m.result); }
    };
    ws.addEventListener('message', f);
    ws.send(JSON.stringify({ id, method, params }));
  });
}

function dims(svg) {
  const m = svg.match(/viewBox="0 0 ([\d.]+) ([\d.]+)"/);
  if (m) return { w: parseFloat(m[1]), h: parseFloat(m[2]) };
  const w = svg.match(/width="([\d.]+)"/);
  const h = svg.match(/height="([\d.]+)"/);
  return { w: w ? parseFloat(w[1]) : 64, h: h ? parseFloat(h[1]) : 64 };
}

(async () => {
  await new Promise(r => server.listen(PORT, '127.0.0.1', r));
  const ch = spawn(CHROME, ['--headless=new', '--disable-gpu', '--no-sandbox',
    '--hide-scrollbars', `--force-device-scale-factor=${SCALE}`,
    '--window-size=400,400', '--remote-debugging-port=9491',
    '--user-data-dir=' + ROOT + '/.figma2/_rastprof', 'about:blank']);
  await sleep(2500);
  const list = await new Promise((res, rej) => {
    http.get('http://127.0.0.1:9491/json', r => {
      let d = ''; r.on('data', c => d += c); r.on('end', () => res(JSON.parse(d)));
    }).on('error', rej);
  });
  const page = list.find(t => t.type === 'page') || list[0];
  const ws = new global.WebSocket(page.webSocketDebuggerUrl);
  await new Promise(r => ws.addEventListener('open', r, { once: true }));
  await cdp(ws, 'Page.enable');
  await cdp(ws, 'Emulation.setDefaultBackgroundColorOverride',
    { color: { r: 0, g: 0, b: 0, a: 0 } });

  let ok = 0;
  for (const f of FILES) {
    const svg = fs.readFileSync(path.join(SRC, f), 'utf8');
    const { w, h } = dims(svg);
    await cdp(ws, 'Page.navigate',
      { url: `http://127.0.0.1:${PORT}/assets/figma_assets/${f}` });
    await sleep(450);
    const { data } = await cdp(ws, 'Page.captureScreenshot', {
      format: 'png',
      captureBeyondViewport: true,
      clip: { x: 0, y: 0, width: w, height: h, scale: SCALE },
    });
    const out = path.join(SRC, f.replace('.svg', '.png'));
    fs.writeFileSync(out, Buffer.from(data, 'base64'));
    console.log('PNG', f.replace('.svg', '.png'), Math.round(w * SCALE) + 'x' + Math.round(h * SCALE));
    ok++;
  }
  console.log('DONE', ok, '/', FILES.length);
  ch.kill();
  process.exit(0);
})();
