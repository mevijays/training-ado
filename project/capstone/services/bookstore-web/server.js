const express = require('express');
const app = express();
const port = process.env.PORT || process.env.WEBSITES_PORT || 3000;

app.get('/', (_req, res) => res.send('<h1>BlueLeaf Bookstore (web)</h1>'));
app.get('/healthz', (_req, res) => res.json({ ok: true }));

app.listen(port, () => console.log('web listening on', port));
