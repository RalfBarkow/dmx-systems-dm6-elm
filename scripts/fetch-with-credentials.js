<script>
  (function () {
    // If you prefer, make this configurable in Elm and pass via flags.
    const BASE = "https://dmx.ralfbarkow.ch";

    function toHeaders(pairs) {
      const h = new Headers();
      (pairs || []).forEach(([k, v]) => h.append(k, v));
      return h;
    }

    function normalizeUrl(url) {
      if (/^https?:\/\//i.test(url)) return url;
      return BASE.replace(/\/$/, "") + "/" + url.replace(/^\//, "");
    }

    app.ports.dmxRequest.subscribe(async (req) => {
      const url = normalizeUrl(req.url);
      const init = {
        method: req.method,
        headers: toHeaders(req.headers),
        credentials: req.withCredentials ? "include" : "same-origin"
      };
      if (req.method !== "GET" && req.method !== "HEAD") {
        init.body = JSON.stringify(req.body ?? null);
        if (!init.headers.has("Content-Type")) {
          init.headers.set("Content-Type", "application/json");
        }
      }
      try {
        const res = await fetch(url, init);
        const text = await res.text();
        let data;
        try { data = text ? JSON.parse(text) : null; } catch (_) { data = text; }
        app.ports.dmxResponse.send({
          id: req.id,
          status: res.status,
          ok: res.ok,
          data
        });
      } catch (e) {
        app.ports.dmxError.send({ id: req.id, message: String(e) });
      }
    });
  })();
</script>
