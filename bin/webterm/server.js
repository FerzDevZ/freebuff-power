#!/usr/bin/env node
// ==============================================================================
// ⚡ FREEBUFF-POWER TEAM COLLABORATIVE WEB TERMINAL (TEAM MEMBER IDENTITY)
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
let activeMembers = new Map(); // ip/token -> username

bash.stdout.on("data", (data) => {
  bashOutput += data.toString();
  if (bashOutput.length > 60000) bashOutput = bashOutput.slice(-60000);
});

bash.stderr.on("data", (data) => {
  bashOutput += data.toString();
  if (bashOutput.length > 60000) bashOutput = bashOutput.slice(-60000);
});

// Auto launch freebuff-power start inside bash
setTimeout(() => {
  bash.stdin.write("freebuff-power start\n");
}, 500);

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  // 1. API: Join Team & Register Member Name
  if (url.pathname === "/api/join" && req.method === "POST") {
    let body = "";
    req.on("data", chunk => body += chunk);
    req.on("end", () => {
      try {
        const json = JSON.parse(body);
        const name = (json.name || "Member").trim().slice(0, 25);
        const token = json.token || Math.random().toString(36).slice(2);
        activeMembers.set(token, { name: name, joinedAt: new Date() });
        
        // Broadcast join message to terminal output
        const joinBanner = `\r\n\x1b[32;1m👋 [TEAM COLLAB] ${name} bergabung ke sesi pair programming!\x1b[0m\r\n`;
        bashOutput += joinBanner;

        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ ok: true, token: token, name: name }));
      } catch (e) {
        res.writeHead(400, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: "Invalid payload" }));
      }
    });
    return;
  }

  // 2. API: Keystrokes & Commands from Registered Members
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

  // 3. API: Poll real-time terminal output & active team roster
  if (url.pathname === "/api/output") {
    res.writeHead(200, {
      "Content-Type": "application/json",
      "Cache-Control": "no-cache"
    });
    const membersList = Array.from(activeMembers.values()).map(m => m.name);
    res.end(JSON.stringify({
      output: bashOutput,
      members: membersList
    }));
    return;
  }

  // 4. Serve Main Team Collab UI with Name Dialog Modal
  res.writeHead(200, {
    "Content-Type": "text/html; charset=utf-8",
    "Access-Control-Allow-Origin": "*"
  });

  res.end(`<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Freebuff-Power Live Team Pair-Programming</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/xterm@5.3.0/css/xterm.css" />
  <script src="https://cdn.jsdelivr.net/npm/xterm@5.3.0/lib/xterm.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/xterm-addon-fit@0.8.0/lib/xterm-addon-fit.js"></script>
  <style>
    * { margin:0; padding:0; box-sizing: border-box; }
    body, html { height:100%; width:100%; background:#0d1117; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; color: #c9d1d9; overflow:hidden; }
    #header { background: #161b22; border-bottom: 1px solid #30363d; padding: 10px 20px; display:flex; justify-content:space-between; align-items:center; }
    #header h1 { font-size: 15px; color: #58a6ff; font-weight: 600; }
    #team-roster { display:flex; align-items:center; gap: 8px; font-size: 12px; }
    .member-tag { background: #238636; color: #fff; padding: 3px 8px; border-radius: 12px; font-weight: bold; }
    #terminal-container { height: calc(100% - 45px); width: 100%; padding: 10px; }
    
    /* Name Modal Overlay */
    #modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.85); backdrop-filter: blur(5px); display: flex; align-items: center; justify-content: center; z-index: 9999; }
    #name-card { background: #161b22; border: 1px solid #30363d; border-radius: 12px; padding: 25px; width: 90%; max-width: 400px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    #name-card h2 { color: #58a6ff; font-size: 18px; margin-bottom: 8px; }
    #name-card p { color: #8b949e; font-size: 13px; margin-bottom: 20px; }
    #name-input { width: 100%; padding: 12px 15px; border-radius: 8px; border: 1px solid #30363d; background: #0d1117; color: #fff; font-size: 15px; outline: none; margin-bottom: 15px; }
    #name-input:focus { border-color: #58a6ff; }
    #join-btn { width: 100%; padding: 12px; background: #238636; color: #fff; font-weight: bold; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; transition: background 0.2s; }
    #join-btn:hover { background: #2ea043; }
  </style>
</head>
<body>
  <!-- Modal Input Nama Tim -->
  <div id="modal-overlay">
    <div id="name-card">
      <h2>🤝 Freebuff Team Collab</h2>
      <p>Masukkan nama kamu untuk bergabung ke sesi live coding tim:</p>
      <form id="join-form">
        <input type="text" id="name-input" placeholder="Contoh: Ferdinand / Andre / Budi" required autofocus />
        <button type="submit" id="join-btn">🚀 Masuk ke Sesi Koding</button>
      </form>
    </div>
  </div>

  <div id="header">
    <h1>⚡ FREEBUFF-POWER — LIVE TEAM COLLABORATION</h1>
    <div id="team-roster">
      <span>👥 Anggota Tim:</span>
      <div id="members-list"><span class="member-tag">● Connecting...</span></div>
    </div>
  </div>

  <div id="terminal-container">
    <div id="terminal" style="height:100%; width:100%;"></div>
  </div>

  <script>
    let myName = localStorage.getItem('collab_name') || '';
    let myToken = localStorage.getItem('collab_token') || '';

    const modal = document.getElementById('modal-overlay');
    const form = document.getElementById('join-form');
    const input = document.getElementById('name-input');
    const membersList = document.getElementById('members-list');

    if (myName) {
      input.value = myName;
    }

    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const val = input.value.trim();
      if (!val) return;
      myName = val;
      localStorage.setItem('collab_name', myName);
      
      fetch('/api/join', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: myName, token: myToken })
      })
      .then(res => res.json())
      .then(data => {
        if (data.token) {
          myToken = data.token;
          localStorage.setItem('collab_token', myToken);
        }
        modal.style.display = 'none';
        term.focus();
      });
    });

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

    // Send keystrokes
    term.onData(data => {
      if (modal.style.display !== 'none') return;
      fetch('/api/input', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ data: data, sender: myName })
      });
    });

    // Poll output & roster
    let lastLength = 0;
    setInterval(() => {
      fetch('/api/output')
        .then(res => res.json())
        .then(data => {
          if (data.output && data.output.length > lastLength) {
            term.write(data.output.slice(lastLength));
            lastLength = data.output.length;
          }
          if (data.members && data.members.length > 0) {
            membersList.innerHTML = data.members.map(m => '<span class="member-tag">● ' + m + '</span>').join(' ');
          }
        });
    }, 150);
  </script>
</body>
</html>`);
});

server.listen(port, "0.0.0.0", () => {
  console.log("Team Collab Server running on 0.0.0.0:" + port);
});
