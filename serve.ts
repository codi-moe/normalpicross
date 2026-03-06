import express from "express";
import { spawn } from "node:child_process";
import { watch, stat, readFile } from "node:fs/promises";
import { join } from "node:path";

const argv = process.argv.slice(2);

const watchFlag = argv.includes("--watch");
const buildFlag = argv.includes("--build");

const changeHandlers: (() => Promise<void>)[] = [];
let changing = false;
let running = false;
async function applyChange() {
  for (const handler of changeHandlers) {
    await handler();
  }
  if (changing) {
    changing = false;
    triggerChange();
  } else {
    running = false;
  }
}
function triggerChange() {
  (async () => {
    if (changing) return;
    if (running) {
      changing = true;
      return;
    }
    running = true;

    await applyChange();
  })();
}

async function build() {
  const process = spawn("make", ["web"], { stdio: "inherit", shell: false });
  await new Promise((ok, ko) => {
    process.once("exit", ok);
    process.once("error", ko);
  });
}

if (watchFlag) {
  const watching = new Map<string, AbortController>();
  function addWatch(path: string) {
    if (watching.has(path)) return;
    const controller = new AbortController();
    watching.set(path, controller);
    (async () => {
      for await (const event of watch(path, {
        recursive: true,
        signal: controller.signal,
        overflow: "throw",
        persistent: true,
      })) {
        if (!event.filename) continue;
        const file = join(path, event.filename);
        const st = await stat(file);
        if (st.isDirectory()) addWatch(file);
        triggerChange();
      }
    })();
  }

  addWatch("conf.lua");
  addWatch("main.lua");
  addWatch("normalpicross");

  changeHandlers.push(async () => {
    console.log("Files changed, rebuilding");
    await build();
  });
}

if (buildFlag) {
  await build();
}

const app = express();

app.use((req, res, next) => {
  res.header("Cross-Origin-Opener-Policy", "same-origin");
  res.header("Cross-Origin-Embedder-Policy", "credentialless");
  next();
});

if (watchFlag) {
  let html = await readFile("out/web/index.html", "utf8");
  const refreshCode = `
    ;(async () => {
      let originalVersion = null
      while (true) {
        try {
          const res = await fetch("/_version")
          const version = await res.text()
          if (!originalVersion) {
            originalVersion = version
            continue
          }
          if (version !== originalVersion) {
            location.reload()
          }
          await new Promise(ok => setTimeout(ok, 100))
        } catch (e) {
          console.error(e)
        }
      }
    })()
  `;
  html = html.replace("</head>", "<script>" + refreshCode + "</script></head>");
  app.get("/", (req, res) => {
    res.header("Content-Type", "text/html");
    res.end(html);
  });
}

app.use(express.static(new URL("out/web", import.meta.url).pathname));

let version = crypto.randomUUID();
changeHandlers.push(async () => {
  version = crypto.randomUUID();
});

app.get("/_version", (req, res) => {
  res.end(version);
});

const srv = app.listen(3000, (err) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log("Listening on", srv.address());
});
