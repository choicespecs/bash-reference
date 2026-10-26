#!/usr/bin/env bash
#
# system-info.sh — Print a quick system summary. Works on Linux and macOS.
#
# Usage: system-info.sh

set -uo pipefail

row() { printf '%-12s %s\n' "$1:" "$2"; }

OS="$(uname -s)"

row "Hostname" "$(hostname)"
row "User"     "$(whoami)"
row "Kernel"   "$OS $(uname -r) ($(uname -m))"
row "Uptime"   "$(uptime | sed -E 's/.*up ([^,]*(, *[0-9]+:[0-9]+)?).*/\1/')"
row "Shell"    "${SHELL:-unknown} (bash ${BASH_VERSION})"

case "$OS" in
  Linux)
    [[ -r /etc/os-release ]] && row "Distro" "$(. /etc/os-release && echo "$PRETTY_NAME")"
    row "CPU"    "$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ //') ($(nproc) cores)"
    row "Memory" "$(free -h | awk '/^Mem:/ {print $3 " used / " $2 " total"}')"
    ;;
  Darwin)
    row "macOS"  "$(sw_vers -productVersion)"
    row "CPU"    "$(sysctl -n machdep.cpu.brand_string) ($(sysctl -n hw.ncpu) cores)"
    row "Memory" "$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 )) GB total"
    ;;
esac

row "Load avg" "$(uptime | sed -E 's/.*load averages?: //')"
row "Disk (/)" "$(df -h / | awk 'NR==2 {print $3 " used / " $2 " (" $5 ")"}')"

ip="$(curl -s --max-time 3 https://ifconfig.me 2>/dev/null || true)"
row "Public IP" "${ip:-unavailable}"
