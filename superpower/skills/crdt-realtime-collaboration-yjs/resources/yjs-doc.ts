import * as Y from 'yjs';
import { WebsocketProvider } from 'y-websocket';

export const ydoc = new Y.Doc();
export const provider = new WebsocketProvider('wss://sync.example.com', 'room-1', ydoc);
export const ytext = ydoc.getText('content');
