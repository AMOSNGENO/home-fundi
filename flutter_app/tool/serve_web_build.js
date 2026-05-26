const fs = require('fs');
const http = require('http');
const path = require('path');

const root = path.resolve(__dirname, '..', 'build', 'web');
const port = Number(process.argv[2] || 8080);

const types = {
  '.css': 'text/css',
  '.html': 'text/html',
  '.ico': 'image/x-icon',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.wasm': 'application/wasm',
};

function sendFile(response, filePath) {
  fs.readFile(filePath, (error, data) => {
    if (error) {
      response.writeHead(404);
      response.end('Not found');
      return;
    }

    response.writeHead(200, {
      'Content-Type': types[path.extname(filePath)] || 'application/octet-stream',
    });
    response.end(data);
  });
}

http
  .createServer((request, response) => {
    const rawPath = decodeURIComponent(request.url.split('?')[0]);
    const requestPath = rawPath === '/' || rawPath === '' ? '/index.html' : rawPath;
    const filePath = path.resolve(root, `.${requestPath}`);

    if (!filePath.startsWith(root)) {
      response.writeHead(403);
      response.end('Forbidden');
      return;
    }

    fs.stat(filePath, (error, stats) => {
      if (!error && stats.isFile()) {
        sendFile(response, filePath);
        return;
      }

      sendFile(response, path.join(root, 'index.html'));
    });
  })
  .listen(port, '127.0.0.1');
