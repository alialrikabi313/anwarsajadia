const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');
const path = require('path');
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const ROOT = 'C:/Users/msi/StudioProjects/anwarsajadia';
const PORT = 8799;
const sleep = ms => new Promise(r => setTimeout(r, ms));
const MIME={'.html':'text/html','.svg':'image/svg+xml'};
const server=http.createServer((req,res)=>{
  let rel=decodeURIComponent(req.url.split('?')[0]).replace(/^\/+/,'');
  let full=path.join(ROOT,rel);
  if(!fs.existsSync(full)){res.writeHead(404);res.end();return;}
  res.writeHead(200,{'Content-Type':MIME[path.extname(full)]||'application/octet-stream'});
  res.end(fs.readFileSync(full));
});
function cdp(ws,method,params={}){return new Promise(r=>{const id=Math.floor(Math.random()*1e9);const f=e=>{const m=JSON.parse(e.data);if(m.id===id){ws.removeEventListener('message',f);r(m.result);}};ws.addEventListener('message',f);ws.send(JSON.stringify({id,method,params}));});}
(async()=>{
  await new Promise(r=>server.listen(PORT,'127.0.0.1',r));
  const ch=spawn(CHROME,['--headless=new','--disable-gpu','--no-sandbox','--hide-scrollbars','--force-device-scale-factor=2','--window-size=480,640','--remote-debugging-port=9488','--user-data-dir='+ROOT+'/.figma2/_pngprof','about:blank']);
  await sleep(2500);
  const list=await new Promise((res,rej)=>{http.get('http://127.0.0.1:9488/json',r=>{let d='';r.on('data',c=>d+=c);r.on('end',()=>res(JSON.parse(d)));}).on('error',rej);});
  const page=list.find(t=>t.type==='page')||list[0];
  const WebSocket=global.WebSocket;
  const ws=new WebSocket(page.webSocketDebuggerUrl);
  await new Promise(r=>ws.addEventListener('open',r,{once:true}));
  await cdp(ws,'Page.enable');
  await cdp(ws,'Page.navigate',{url:`http://127.0.0.1:${PORT}/.figma2/preview_png.html`});
  await sleep(2500);
  const {data}=await cdp(ws,'Page.captureScreenshot',{format:'png',captureBeyondViewport:true,clip:{x:0,y:0,width:480,height:640,scale:1}});
  fs.writeFileSync(ROOT+'/.figma2/PREVIEW_png.png',Buffer.from(data,'base64'));
  console.log('saved');
  ch.kill();process.exit(0);
})();
