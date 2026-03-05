import express from "express";

const app = express();

app.use((req, res, next) => {
  res.header("Cross-Origin-Opener-Policy", "same-origin");
  res.header("Cross-Origin-Embedder-Policy", "credentialless");
  next();
});

app.use(express.static(new URL("out/web", import.meta.url).pathname));

const srv = app.listen(3000, (err) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log("Listening on", srv.address());
});
