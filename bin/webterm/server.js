#!/usr/bin/env node
// ==============================================================================
// ⚡ FREEBUFF-POWER TURBO WEBSOCKET & HTTP TWO-WAY BROWSER TERMINAL
// ==============================================================================
const http = require("http");
const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const port = process.env.PORT || 7681;
const manicodeDir = path.join(process.env.HOME, ".config/manicode");

// Clean stale locks
try {
  if (fs.existsSync(manicodeDir)) {
    const files = fs.readdirSync(manicodeDir);
    for (const f of files) {
      if (f.endsWith(".lock") || f.endsWith(".sock") || f === "session-state.json") {
        fs.unlinkSync(path.join(manicodeDir, f));
      }
    }
  }
} catch (e) {}

try {
  const { execSync } = require("child_process");
  execSync("pkill -9 -f freebuff 2>/dev/null || true");
} catch (e) {}

// Spawn bash process with PTY pipe
const bash = spawn("bash", ["-l"], {
  env: { ...process.env, TERM: "xterm-256color" },
  stdio: ["pipe", "pipe", "pipe"]
});

let bashOutput = "";
let sseClients = [];

function broadcast(data) {
  for (const client of sseClients) {
    try {
      client.write(`data: ${JSON.stringify({ chunk: data })}\n\n`);
    } catch (e) {}
  }
}

bash.stdout.on("data", (data) => {
  const str = data.toString();
  bashOutput += str;
  if (bashOutput.length > 80000) bashOutput = bashOutput.slice(-80000);
  broadcast(str);
});

bash.stderr.on("data", (data) => {
  const str = data.toString();
  bashOutput += str;
  if (bashOutput.length > 80000) bashOutput = bashOutput.slice(-80000);
  broadcast(str);
});

setTimeout(() => {
  bash.stdin.write("freebuff-power start\n");
}, 200);

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  // Instant SSE Stream
  if (url.pathname === "/api/stream") {
    res.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache, no-transform",
      "Connection": "keep-alive",
      "X-Accel-Buffering": "no",
      "Access-Control-Allow-Origin": "*"
    });
    res.write(`data: ${JSON.stringify({ chunk: bashOutput })}\n\n`);
    sseClients.push(res);

    req.on("close", () => {
      sseClients = sseClients.filter(c => c !== res);
    });
    return;
  }

  // Turbo Instant Keystroke Delivery (Synchronous write to stdin)
  if (url.pathname === "/api/input") {
    let body = "";
    req.on("data", chunk => body += chunk);
    req.on("end", () => {
      if (body) {
        try {
          const json = JSON.parse(body);
          if (json.data) bash.stdin.write(json.data);
        } catch (e) {
          bash.stdin.write(body);
        }
      }
      res.writeHead(200, { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" });
      res.end('{"ok":true}');
    });
    return;
  }

  // Render High-Speed Terminal UI
  res.writeHead(200, {
    "Content-Type": "text/html; charset=utf-8",
    "Access-Control-Allow-Origin": "*"
  });

  res.end(`<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Freebuff-Power Ultra-Fast Collaborative Terminal</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/xterm@5.3.0/css/xterm.css" />
  <script src="https://cdn.jsdelivr.net/npm/xterm@5.3.0/lib/xterm.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/xterm-addon-fit@0.8.0/lib/xterm-addon-fit.js"></script>
  <style>
    * { margin:0; padding:0; box-sizing: border-box; }
    body, html { height:100%; width:100%; background:#0d1117; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; color: #c9d1d9; overflow:hidden; }
    #header { background: #161b22; border-bottom: 1px solid #30363d; padding: 10px 20px; display:flex; justify-content:space-between; align-items:center; }
    #header h1 { font-size: 15px; color: #58a6ff; font-weight: 600; }
    #badge { background: #238636; color: #fff; font-size: 11px; padding: 3px 8px; border-radius: 12px; font-weight: bold; }
    #terminal-container { height: calc(100% - 45px); width: 100%; padding: 10px; }
  </style>
</head>
<body>
  <div id="header">
    <h1>⚡ FREEBUFF-POWER — ULTRA-FAST LIVE TERMINAL (0ms LAG)</h1>
    <span id="badge">● TURBO LIVE CONNECTED</span>
  </div>
  <div id="terminal-container">
    <div id="terminal" style="height:100%; width:100%;"></div>
  </div>

  <script>
    const term = new Terminal({
      cursorBlink: true,
      fontFamily: 'Fira Code, Consolas, Monaco, monospace',
      fontSize: 14,
      theme: {
        background: '#0d1117',
        foreground: '#c9d1d9',
        cursor: '#58a6ff',
        selectionBackground: '#264f78'
      }
    });
    const fitAddon = new FitAddon.FitAddon();
    term.loadAddon(fitAddon);
    term.open(document.getElementById('terminal'));
    fitAddon.fit();
    term.focus();
    window.addEventListener('resize', () => fitAddon.fit());

    // Instant Keystrokes via Beacon / Fast HTTP Post
    let inputQueue = '';
    let sendTimeout = null;

    term.onData(data => {
      inputQueue += data;
      if (!sendTimeout) {
        sendTimeout = setTimeout(() => {
          const payload = JSON.stringify({ data: inputQueue });
          inputQueue = '';
          sendTimeout = null;
          fetch('/api/input', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: payload,
            keepalive: true
          });
        }, 5);
      }
    });

    document.getElementById('terminal-container').addEventListener('click', () => {
      term.focus();
    });

    // Real-Time SSE Stream with auto-reconnect
    function connectStream() {
      const evtSource = new EventSource('/api/stream');
      evtSource.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          if (data.chunk) term.write(data.chunk);
        } catch(e) {}
      };
      evtSource.onerror = () => {
        evtSource.close();
        setTimeout(connectStream, 1000);
      };
    }
    connectStream();
  </script>
</body>
</html>`);
});

server.listen(port, "0.0.0.0", () => {
  console.log("Turbo Terminal Server active on port " + port);
});
