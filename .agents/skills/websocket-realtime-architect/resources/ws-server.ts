// Production WebSocket Server with Heartbeat (ws library in TypeScript)
import { WebSocketServer, WebSocket } from 'ws';

interface ExtendedWebSocket extends WebSocket {
  isAlive: boolean;
  userId?: string;
}

const wss = new WebSocketServer({ port: 8081 });

wss.on('connection', (ws: ExtendedWebSocket) => {
  ws.isAlive = true;

  ws.on('pong', () => {
    ws.isAlive = true;
  });

  ws.on('message', (data) => {
    // Process message or forward to Redis PubSub
  });
});

// Periodic heartbeat interval
const interval = setInterval(() => {
  wss.clients.forEach((client) => {
    const ws = client as ExtendedWebSocket;
    if (!ws.isAlive) {
      return ws.terminate();
    }
    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

wss.on('close', () => {
  clearInterval(interval);
});
