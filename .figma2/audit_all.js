// Screenshot many app routes in ONE headless Chrome session for a final audit.
const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const ROOT = 'C:/Users/msi/StudioProjects/anwarsajadia/build/web';
const OUT = 'C:/Users/msi/StudioProjects/anwarsajadia/.figma2/audit/';
const PORT = 8761;
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const BOOT = 15000;
const NAV = 6000;
// label : route (empty route = home via splash)
const ROUTES = [
  ['qibla', 'more/qibla'],
  ['surah1', 'quran/surah/1'],
  ['martyrs', 'martyrs'],
  ['about', 'about-app'],
  ['media', 'media'],
  ['quiz', 'more/quiz'],
];
const MIME = { '.html':'text/html','.js':'text/javascript','.json':'application/json','.png':'image/png','.svg':'image/svg+xml','.css':'text/css','.wasm':'application/wasm','.ttf':'font/ttf','.otf':'font/otf','.bin':'application/octet-stream' };
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
    const onMsg = ev => { const m = JSON.parse(ev.data); if (m.id === id) { ws.removeEventListener('message', onMsg); resolve(m.result); } };
    ws.addEventListener('message', onMsg);
    ws.send(JSON.stringify({ id, method, params }));
  });
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  await new Promise(r => server.listen(PORT, '127.0.0.1', r));
  const chrome = spawn(CHROME, ['--headless=new','--disable-gpu','--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--hide-scrollbars','--force-device-scale-factor=2','--window-size=430,1700','--remote-debugging-port=9461','--user-data-dir=C:/Users/msi/StudioProjects/anwarsajadia/.figma2/_auditprof','about:blank']);
  await sleep(2500);
  const list = await new Promise((res, rej) => { http.get('http://127.0.0.1:9461/json', r => { let d=''; r.on('data',c=>d+=c); r.on('end',()=>res(JSON.parse(d))); }).on('error', rej); });
  const page = list.find(t => t.type === 'page') || list[0];
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise(r => ws.addEventListener('open', r, { once: true }));
  await cdp(ws, 'Page.enable');
  let first = true;
  for (const [label, route] of ROUTES) {
    await cdp(ws, 'Page.navigate', { url: `http://127.0.0.1:${PORT}/?shoot=${encodeURIComponent('/' + route)}` });
    await sleep(first ? BOOT : NAV + 9000); // splash adds ~2.4s each reload
    first = false;
    const { data } = await cdp(ws, 'Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(OUT + label + '.png', Buffer.from(data, 'base64'));
    console.log('shot', label, fs.statSync(OUT + label + '.png').size);
  }
  ws.close(); chrome.kill(); server.close(); process.exit(0);
})().catch(e => { console.error('ERR', e); process.exit(1); });
