#!/usr/bin/env node
// ==============================================================================
// ⚡ FREEBUFF-POWER INTERACTIVE FULL-DUPLEX WEB TERMINAL
// ==============================================================================
const http = require("http");
const { spawn } = require("child_process");

const port = process.env.PORT || 7681;

// Spawn bash process with PTY pipe
const bash = spawn("bash", ["-l"], {
  env: process.env,
  stdio: ["pipe", "pipe", "pipe"]
});

let bashOutput = "";
bash.stdout.on("data", (data) => {
  bashOutput += data.toString();
  if (bashOutput.length > 50000) bashOutput = bashOutput.slice(-50000);
});

bash.stderr.on("data", (data) => {
  bashOutput += data.toString();
  if (bashOutput.length > 50000) bashOutput = bashOutput.slice(-50000);
});

// Auto launch freebuff-power start inside bash
setTimeout(() => {
  bash.stdin.write("freebuff-power start\n");
}, 500);

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  // API to receive keystrokes/commands from browser
  if (url.pathname === "/api/input" && req.method === "POST") {
    let body = "";
    req.on("data", chunk => body += chunk);
    req.on("end", () => {
      try {
        const json = JSON.parse(body);
        if (json.data) {
          bash.stdin.write(json.data);
        }
      } catch (e) {
        bash.stdin.write(body);
      }
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ ok: true }));
    });
    return;
  }

  // API to poll real-time terminal output
  if (url.pathname === "/api/output") {
    res.writeHead(200, {
      "Content-Type": "text/plain; charset=utf-8",
      "Cache-Control": "no-cache"
    });
    res.end(bashOutput);
    return;
  }

  // Serve Main Full-Interactive UI
  res.writeHead(200, {
    "Content-Type": "text/html; charset=utf-8",
    "Access-Control-Allow-Origin": "*"
  });

  res.end(`<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Freebuff-Power Live Interactive Terminal</title>
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
    <h1>⚡ FREEBUFF-POWER — LIVE FULL-INTERACTIVE TERMINAL</h1>
    <span id="badge">● INTERACTIVE ACTIVE</span>
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
    window.addEventListener('resize', () => fitAddon.fit());

    // 1. Send all keystrokes from browser to backend bash process
    term.onData(data => {
      fetch('/api/input', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ data: data })
      });
    });

    // 2. Poll bash output continuously
    let lastLength = 0;
    setInterval(() => {
      fetch('/api/output')
        .then(res => res.text())
        .then(text => {
          if (text.length > lastLength) {
            term.write(text.slice(lastLength));
            lastLength = text.length;
          }
        });
    }, 150);
  </script>
</body>
</html>`);
});

server.listen(port, "0.0.0.0", () => {
  console.log("Interactive Web Terminal server running on 0.0.0.0:" + port);
});
