#!/usr/bin/env node
import esbuild from 'esbuild';
import http from 'http';
import { options } from './common';

async function main() {
  // Prepares the server
  const ctx = await esbuild.context(options);
  await ctx.watch(); // must be called before serve
  const { host, port } = await ctx.serve({ servedir: 'dist' });

  http
    .createServer((req, res) => {
      const forwardRequest = (path?: string) => {
        const options = {
          hostname: host,
          port,
          path,
          method: req.method,
          headers: req.headers,
        };

        const proxyReq = http.request(options, (proxyRes) => {
          if (!path || path === '/') {
            console.log('Redirecting', path);
            return forwardRequest('/index.html');
          } else {
            console.log('Serving', path, proxyRes.statusCode, proxyRes.headers);
            res.writeHead(proxyRes.statusCode || 500, proxyRes.headers);
            proxyRes.pipe(res, { end: true });
          }
        });

        req.pipe(proxyReq, { end: true });
      };

      forwardRequest(req.url);
    })
    .listen(1234);
}

main();
