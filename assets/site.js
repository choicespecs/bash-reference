const REPO = "https://github.com/choicespecs/bash-reference/blob/main/scripts/";
const SCRIPTS = [
  ["script-template.sh",   "Boilerplate with strict mode, getopts, logging, and trap cleanup. Start new scripts here."],
  ["backup.sh",            "Timestamped .tar.gz backups that keep only the N newest."],
  ["cleanup-old-files.sh", "Delete files older than N days, with a dry run by default and a name pattern filter."],
  ["batch-rename.sh",      "Bulk rename: find/replace, lowercase, spaces→underscores, sequential numbering."],
  ["disk-usage-alert.sh",  "Warn and exit non-zero when a filesystem is over a usage threshold. Built for cron."],
  ["find-large-files.sh",  "List the largest files under a directory, in human-readable sizes."],
  ["log-analyzer.sh",      "Summarize an Nginx/Apache access log: top IPs, paths, status codes, 404s."],
  ["git-update-all.sh",    "Run git pull in every repo under a folder, skipping repos with local changes."],
  ["healthcheck.sh",       "Check a list of URLs for HTTP status and response time."],
  ["retry.sh",             "Re-run a command with exponential backoff until it succeeds."],
  ["system-info.sh",       "Quick system summary (OS, CPU, memory, disk, IP) for Linux and macOS."],
];

// Copy buttons
function addCopy(pre) {
  if (pre.querySelector(".copy")) return;
  const btn = document.createElement("button");
  btn.className = "copy"; btn.textContent = "Copy";
  btn.addEventListener("click", async () => {
    try { await navigator.clipboard.writeText(pre.querySelector("code").innerText); btn.textContent = "Copied!"; }
    catch { btn.textContent = "Failed"; }
    setTimeout(() => (btn.textContent = "Copy"), 1500);
  });
  pre.appendChild(btn);
}
document.querySelectorAll("pre code").forEach(c => { hljs.highlightElement(c); addCopy(c.parentElement); });

// Script cards + viewer
const cards = document.getElementById("script-cards");
const navLinks = [...document.querySelectorAll("nav.side a")];
const viewer = document.getElementById("viewer");
const codeEl = document.getElementById("viewer-code");
if (cards) SCRIPTS.forEach(([name, desc]) => {
  const b = document.createElement("button");
  b.className = "card";
  b.innerHTML = `<div class="name"></div><div class="desc"></div>`;
  b.querySelector(".name").textContent = name;
  b.querySelector(".desc").textContent = desc;
  b.addEventListener("click", () => showScript(name, b));
  cards.appendChild(b);
});
async function showScript(name, card) {
  document.querySelectorAll(".card").forEach(c => c.classList.toggle("active", c === card));
  viewer.classList.remove("hidden");
  document.getElementById("viewer-name").textContent = name;
  document.getElementById("viewer-raw").href = "scripts/" + name;
  document.getElementById("viewer-gh").href = REPO + name;
  codeEl.removeAttribute("data-highlighted");
  codeEl.textContent = "Loading…";
  try {
    const res = await fetch("scripts/" + name);
    if (!res.ok) throw new Error(res.status);
    codeEl.textContent = await res.text();
  } catch {
    codeEl.textContent = `# Couldn't load ${name} here. View it on GitHub:\n# ${REPO}${name}`;
  }
  hljs.highlightElement(codeEl);
  addCopy(codeEl.parentElement);
  viewer.scrollIntoView({ behavior: "smooth", block: "start" });
}

// Mobile menu
const nav = document.getElementById("nav");
document.getElementById("menu-btn").addEventListener("click", () => nav.classList.toggle("open"));
navLinks.forEach(a => a.addEventListener("click", () => nav.classList.remove("open")));

// Theme toggle
const root = document.documentElement;
try { const t = localStorage.getItem("theme"); if (t) root.dataset.theme = t; } catch {}
document.getElementById("theme-btn").addEventListener("click", () => {
  const dark = root.dataset.theme ? root.dataset.theme === "dark" : matchMedia("(prefers-color-scheme: dark)").matches;
  root.dataset.theme = dark ? "light" : "dark";
  try { localStorage.setItem("theme", root.dataset.theme); } catch {}
});
