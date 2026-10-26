# Bash Reference

A practical Bash scripting reference: syntax, script structure, common commands, and tested example scripts you can use as-is.

**Live site:** https://choicespecs.github.io/bash-reference/

## What's inside

- **Reference:** script structure and strict mode, variables and quoting, parameter expansion, arrays, conditionals, loops, functions, `getopts`, redirection, here-docs, traps, debugging, and best practices
- **Common commands:** files, `find`, `grep`, `sed`, `awk`, processes, cron, networking, archives, shell shortcuts
- **Example scripts** in [`scripts/`](scripts/):

| Script | Purpose |
|---|---|
| `script-template.sh` | Boilerplate with strict mode, getopts, logging, and trap cleanup |
| `backup.sh` | Timestamped `.tar.gz` backups that keep only the N newest |
| `cleanup-old-files.sh` | Delete files older than N days (dry run by default) |
| `batch-rename.sh` | Bulk rename: replace, lowercase, spaces→underscores, numbering |
| `disk-usage-alert.sh` | Alert when a filesystem is over a usage threshold |
| `find-large-files.sh` | List the largest files under a directory |
| `log-analyzer.sh` | Summarize Nginx/Apache access logs |
| `git-update-all.sh` | `git pull` every repo in a folder, skipping repos with local changes |
| `healthcheck.sh` | Check URLs for HTTP status and response time |
| `retry.sh` | Retry a command with exponential backoff |
| `system-info.sh` | Quick system summary for Linux and macOS |

## Usage

```bash
git clone https://github.com/choicespecs/bash-reference.git
cd bash-reference/scripts
./script-template.sh -h
```

Every script prints usage notes in its header comment.

## Local preview

The site is a single static `index.html`. It fetches the scripts, so preview it through a local server rather than opening the file directly:

```bash
python3 -m http.server 8000   # then open http://localhost:8000
```
