import { WebSocketServer } from 'ws';

export default function startTextEchoServer(port) {
  const wss = new WebSocketServer({ port });

  console.log(`Echo server starts at port:${port}`);

  wss.on('connection', (ws) => {
    ws.on('message', (message, isBinary) => {
      if (!isBinary) {
        ws.send(`${message}`);
      } else {
        console.warn('ignore binary message');
      }
    });
  });

  // return a function to stop the server
  return () => wss.close();
}
