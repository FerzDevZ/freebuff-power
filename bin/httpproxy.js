#!/usr/bin/env node
// ==============================================================================
// 🌐 FREEBUFF-POWER ULTRA-LIGHT HTTP-TO-SOCKS5 BRIDGE (Zero Dependency)
// ==============================================================================
const http = require("http");
const net = require("net");

const HTTP_PORT = parseInt(process.env.HTTP_PROXY_PORT || "8118", 10);
const SOCKS_HOST = process.env.SOCKS_HOST || "127.0.0.1";
const SOCKS_PORT = parseInt(process.env.SOCKS_PORT || "1080", 10);

function createSocksConnection(targetHost, targetPort, clientSocket, head) {
  const socksSocket = net.connect(SOCKS_PORT, SOCKS_HOST, () => {
    // SOCKS5 greeting: VER 5, 1 METHOD, NO AUTH (0x00)
    socksSocket.write(Buffer.from([0x05, 0x01, 0x00]));
  });

  let state = "GREETING";

  socksSocket.on("data", (chunk) => {
    if (state === "GREETING") {
      if (chunk[0] !== 0x05 || chunk[1] !== 0x00) {
        clientSocket.destroy();
        socksSocket.destroy();
        return;
      }
      state = "CONNECT";
      // SOCKS5 request: VER 5, CMD CONNECT (0x01), RSV 0, ATYP DOMAIN (0x03)
      const hostBuf = Buffer.from(targetHost);
      const portBuf = Buffer.alloc(2);
      portBuf.writeUInt16BE(targetPort, 0);
      const req = Buffer.concat([
        Buffer.from([0x05, 0x01, 0x00, 0x03, hostBuf.length]),
        hostBuf,
        portBuf
      ]);
      socksSocket.write(req);
    } else if (state === "CONNECT") {
      if (chunk[0] !== 0x05 || chunk[1] !== 0x00) {
        clientSocket.destroy();
        socksSocket.destroy();
        return;
      }
      state = "CONNECTED";
      clientSocket.write("HTTP/1.1 200 Connection Established\r\n\r\n");
      if (head && head.length > 0) socksSocket.write(head);
      clientSocket.pipe(socksSocket);
      socksSocket.pipe(clientSocket);
    }
  });

  socksSocket.on("error", () => {
    try { clientSocket.write("HTTP/1.1 502 Bad Gateway\r\n\r\n"); } catch(e){}
    clientSocket.destroy();
  });
  clientSocket.on("error", () => socksSocket.destroy());
}

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("Freebuff-Power Local HTTP-to-SOCKS5 Proxy Active\n");
});

server.on("connect", (req, clientSocket, head) => {
  const [host, port] = req.url.split(":");
  createSocksConnection(host, parseInt(port || 443, 10), clientSocket, head);
});

server.listen(HTTP_PORT, "127.0.0.1", () => {
  if (process.send) process.send("ready");
});

process.on("SIGTERM", () => process.exit(0));
process.on("SIGINT", () => process.exit(0));
