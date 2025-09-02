import express from "express";
import { createProxyMiddleware } from "http-proxy-middleware";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();

const TARGET = "https://dmx.ralfbarkow.ch"; // DMX v5.3.5

// 1) Serve the example files at /
app.use(express.static(__dirname)); // serves index.html, main.js, etc.

// 2) Same-origin proxies for DMX plugin paths
const common = {
  target: TARGET,
  changeOrigin: true,
  secure: true,   // set to false only if DMX uses self-signed TLS
  logLevel: "warn",
};
app.use("/core",      createProxyMiddleware(common));
app.use("/topicmaps", createProxyMiddleware(common));
app.use("/search",    createProxyMiddleware(common));

// 3) Handle OPTIONS locally (no fancy patterns; Express 5-safe)
app.use((req, res, next) => {
  if (req.method === "OPTIONS") {
    // Same-origin; no CORS headers needed. Just acknowledge.
    return res.sendStatus(204);
  }
  next();
});

const PORT = process.env.PORT || 5173;
app.listen(PORT, () => {
  console.log(`Example running at http://localhost:${PORT}`);
});
