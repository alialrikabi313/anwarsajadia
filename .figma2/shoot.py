"""Serve build/web and screenshot the running Flutter app at mobile size.

Usage: python .figma2/shoot.py <out.png> [path] [wait_ms]
Starts a static server on build/web, opens headless Chrome at 430x932,
waits for the app to boot, screenshots to <out.png>.
"""
import http.server, socketserver, threading, subprocess, sys, os, time, functools

ROOT = r'C:/Users/msi/StudioProjects/anwarsajadia/build/web'
OUT = sys.argv[1] if len(sys.argv) > 1 else r'C:/Users/msi/StudioProjects/anwarsajadia/.figma2/shot.png'
PATH = sys.argv[2] if len(sys.argv) > 2 else ''
WAIT_MS = int(sys.argv[3]) if len(sys.argv) > 3 else 9000
WIN_H = int(sys.argv[4]) if len(sys.argv) > 4 else 932
PORT = 8731
CHROME = r'C:/Program Files/Google/Chrome/Application/chrome.exe'

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=ROOT, **k)

    def do_GET(self):
        # Serve real files; otherwise fall back to index.html (SPA routing).
        rel = self.path.split('?', 1)[0].split('#', 1)[0].lstrip('/')
        full = os.path.join(ROOT, rel)
        if rel and os.path.isfile(full):
            return super().do_GET()
        self.path = '/index.html'
        return super().do_GET()


httpd = socketserver.TCPServer(('127.0.0.1', PORT), SPAHandler)
t = threading.Thread(target=httpd.serve_forever, daemon=True)
t.start()
url = f'http://127.0.0.1:{PORT}/{PATH}'
print('serving', ROOT, 'at', url)

prof = r'C:/Users/msi/StudioProjects/anwarsajadia/.figma2/_chromeprof'
cmd = [
    CHROME, '--headless=new', '--disable-gpu', '--no-sandbox',
    '--use-gl=angle', '--use-angle=swiftshader',
    '--hide-scrollbars', '--force-device-scale-factor=2',
    f'--window-size=430,{WIN_H}',
    f'--user-data-dir={prof}',
    f'--virtual-time-budget={WAIT_MS}',
    f'--screenshot={OUT}',
    url,
]
print('running chrome...')
r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
print('exit', r.returncode)
if r.stderr:
    print(r.stderr[-800:])
httpd.shutdown()
print('saved', OUT, 'exists:', os.path.exists(OUT),
      os.path.getsize(OUT) if os.path.exists(OUT) else '')
