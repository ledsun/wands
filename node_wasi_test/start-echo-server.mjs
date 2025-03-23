import { WebSocketServer } from 'ws';

export default function startTextEchoServer(port) {
  const wss = new WebSocketServer({ port });

  console.log(`Echo server starts at port:${port}`);

  wss.on('connection', (ws) => {
    ws.on('message', (message, isBinary) => {
      ws.send(message, { binary: isBinary });
    });
  });

  // return a function to stop the server
  return () => wss.close();
}
