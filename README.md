# linux-command-utils-fish

71 fish shell quick-command functions for Linux and macOS, covering GPU monitoring, Docker, networking, disk, git, logs, services, and more. All functions follow a `q<name>` naming convention and support `-h` for usage help.

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/yourzero/linux-command-utils-fish/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/yourzero/linux-command-utils-fish.git
cd linux-command-utils-fish && ./install.sh
```

The installer will prompt before enabling optional features.

## What gets installed

### Core functions (`fish-functions.tar.gz`)

| Category | Commands |
|---|---|
| **Disk** | `qdf` `qduh` `qdubig` `qmount` |
| **Networking** | `qip` `qip6` `qpubip` `qroute` `qport` `qportall` `qdns` `qping` `qtrace` `qmac` `qwifi` |
| **Processes** | `qtop` `qtopmem` `qkill` `qmem` `qcpu` `quptime` `qtemp` `qwho` `qopenfiles` |
| **Logs** | `qlog` `qlogf` `qlasterr` `qdmesg` |
| **Files** | `qfind` `qgrep` `qrecent` `qbig` `qext` `qdupes` |
| **Git** | `qgst` `qglog` `qgdiff` `qgclean` `qgbr` `qgpush` |
| **Docker** | `qdps` `qdpsall` `qdlogs` `qdclean` `qdstats` `qdsh` `qdnet` |
| **Services** | `qsvc` `qsvcs` `qsvca` |
| **Packages** | `qpkg` `qupdate` |
| **NVIDIA GPU** | `qgpu` `qgpuwatch` `qgpuproc` |
| **vLLM** | `qvllm` `qvllmlog` |
| **SSH** | `qsshkeys` `qsshagent` |
| **Misc** | `qenv` `qpath` `qhist` `qalias` `qtime` `qwatch` `qb64` `qjson` `qwhat` `qsum` `qcheatsheet` `qhelp` |

Run `qcheatsheet` after install to see all functions with descriptions, or `qhelp` for a grouped reference card.

### Optional: login cheatsheet

The installer can add `qcheatsheet` to your fish login so the reference card appears every time you open a shell or SSH in.

### Optional: command suggestions (`__q_suggest`)

Watches the commands you run and suggests a `q`-equivalent when one exists. Fires only in interactive sessions.

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
...
  ↳ qdf — df sorted by usage, no tmpfs noise
```

## Requirements

- [fish shell](https://fishshell.com/) 3.x — Linux or macOS

## All commands support `-h`

```
$ qdf -h
Usage: qdf [path]
  Human-readable df, filtered/sorted. Default path = /
```

---

## Command reference

### Disk & storage

| Command | Usage | Description |
|---|---|---|
| `qdf` | `qdf [path]` | Disk free, human-readable, sorted by usage, no tmpfs noise. Default path: `/` |
| `qduh` | `qduh [path] [depth]` | `du` summary sorted largest-first. Default: current dir, depth 1 |
| `qdubig` | `qdubig [path] [n]` | Top N largest files/dirs under a path. Default: `/`, top 20 |
| `qmount` | `qmount` | Mounted filesystems in a clean table, skipping pseudo-mounts |

### Networking

| Command | Usage | Description |
|---|---|---|
| `qip` | `qip` | Real IPv4 addresses only — skips loopback, link-local, and virtual interfaces |
| `qip6` | `qip6` | Real IPv6 addresses only — skips loopback and link-local |
| `qpubip` | `qpubip` | Your public internet-facing IP (with fallback URLs) |
| `qroute` | `qroute` | Default gateway and full routing table |
| `qport` | `qport [port]` | Listening ports; optionally filter by port number |
| `qportall` | `qportall` | All active TCP connections |
| `qdns` | `qdns <hostname>` | A, AAAA, MX, NS, and TXT records for a hostname |
| `qping` | `qping <host>` | Ping with 5 packets |
| `qtrace` | `qtrace <host>` | Traceroute using the best available tool (`mtr` or `traceroute`) |
| `qmac` | `qmac` | MAC addresses for real interfaces |
| `qwifi` | `qwifi` | Current WiFi SSID and signal strength |

### Processes & health

| Command | Usage | Description |
|---|---|---|
| `qtop` | `qtop` | Top 15 processes by CPU, clean output |
| `qtopmem` | `qtopmem` | Top 15 processes by RAM |
| `qkill` | `qkill <name>` | Find and kill a process by name, shows matches first and prompts for confirmation |
| `qmem` | `qmem` | Memory and swap usage summary |
| `qcpu` | `qcpu` | CPU model, core count, and current load average |
| `quptime` | `quptime` | Uptime and load average, human-readable |
| `qtemp` | `qtemp` | CPU temperatures via `lm-sensors` and GPU temperature via `nvidia-smi` |
| `qwho` | `qwho` | Who is logged in and what they are doing |
| `qopenfiles` | `qopenfiles` | Top 10 processes by open file descriptor count |

### Logs

| Command | Usage | Description |
|---|---|---|
| `qlog` | `qlog [unit]` | systemd journal errors and warnings; optionally filter by unit name |
| `qlogf` | `qlogf <unit>` | Live-follow systemd journal for a unit |
| `qlasterr` | `qlasterr` | Errors from the current boot only |
| `qdmesg` | `qdmesg` | `dmesg` warnings and errors with human-readable timestamps |

### Files & search

| Command | Usage | Description |
|---|---|---|
| `qfind` | `qfind <pattern> [path]` | Find files by name pattern, suppressing permission errors |
| `qgrep` | `qgrep <pattern> [path]` | Recursive grep, case-insensitive, with color |
| `qrecent` | `qrecent [path] [minutes]` | Files modified in the last N minutes. Default: current dir, 60 min |
| `qbig` | `qbig [path] [n]` | N largest files in a directory tree. Default: current dir, top 20 |
| `qext` | `qext [path]` | Unique file extensions with counts |
| `qdupes` | `qdupes [path]` | Find duplicate files by MD5 checksum |

### Git

| Command | Usage | Description |
|---|---|---|
| `qgst` | `qgst` | `git status` and recent log in one view |
| `qglog` | `qglog [n]` | Pretty git log with author and date. Default: last 20 commits |
| `qgdiff` | `qgdiff` | Staged and unstaged diff summary |
| `qgclean` | `qgclean` | Show untracked files and prompt before removing them |
| `qgbr` | `qgbr` | Branches sorted by last commit date |
| `qgpush` | `qgpush <message>` | Stage all changes, commit with message, and push in one shot |

### Docker

| Command | Usage | Description |
|---|---|---|
| `qdps` | `qdps` | Running containers in a clean format |
| `qdpsall` | `qdpsall` | All containers including stopped |
| `qdlogs` | `qdlogs <name>` | Tail container logs (last 100 lines + follow) |
| `qdclean` | `qdclean` | Remove stopped containers, dangling images, and unused networks (with confirmation) |
| `qdstats` | `qdstats` | Live resource usage for all running containers |
| `qdsh` | `qdsh <name> [shell]` | Shell into a running container. Default shell: `bash`, fallback: `sh` |
| `qdnet` | `qdnet` | Docker networks |

### Services (systemd)

| Command | Usage | Description |
|---|---|---|
| `qsvc` | `qsvc <name>` | Status of a systemd service |
| `qsvcs` | `qsvcs` | All failed services |
| `qsvca` | `qsvca` | All active (running) services |

### Packages (apt)

| Command | Usage | Description |
|---|---|---|
| `qpkg` | `qpkg <name>` | Check if a package is installed, or search available packages |
| `qupdate` | `qupdate` | `apt update`, show upgradable packages, prompt before upgrading |

### NVIDIA GPU

| Command | Usage | Description |
|---|---|---|
| `qgpu` | `qgpu` | GPU temperature, load, VRAM usage, and power draw |
| `qgpuwatch` | `qgpuwatch` | Live GPU stats refreshed every 2 seconds (Ctrl+C to exit) |
| `qgpuproc` | `qgpuproc` | Processes currently using the GPU |

### vLLM

| Command | Usage | Description |
|---|---|---|
| `qvllm` | `qvllm` | Check vLLM server status and loaded model. Respects `$VLLM_HOST` / `$VLLM_PORT` |
| `qvllmlog` | `qvllmlog` | Tail the vLLM systemd service log, or suggest `qdlogs vllm` if running in Docker |

### SSH

| Command | Usage | Description |
|---|---|---|
| `qsshkeys` | `qsshkeys` | List fingerprints for all public keys in `~/.ssh/` |
| `qsshagent` | `qsshagent` | Load all private keys from `~/.ssh/` into `ssh-agent` |

### Misc

| Command | Usage | Description |
|---|---|---|
| `qenv` | `qenv [filter]` | Environment variables sorted; optional substring filter |
| `qpath` | `qpath` | `$PATH` entries, one per line with index |
| `qhist` | `qhist <pattern>` | Search command history for a pattern |
| `qalias` | `qalias` | List all defined abbreviations and non-builtin functions |
| `qtime` | `qtime <cmd> [args]` | Time a command and report elapsed milliseconds |
| `qwatch` | `qwatch <interval> <cmd>` | `watch` wrapper — e.g. `qwatch 5 qgpu` |
| `qb64` | `qb64 <str>` / `qb64 -d <str>` | Base64 encode a string, or decode with `-d` |
| `qjson` | `qjson [file]` | Pretty-print JSON from a file or stdin |
| `qwhat` | `qwhat <cmd>` | `which` location and man page summary for a command |
| `qsum` | `qsum <file>` | SHA256 checksum of a file |
| `qcheatsheet` | `qcheatsheet [filter]` | Auto-generated list of every installed function and its description |
| `qhelp` | `qhelp` | Grouped reference card (static, manually curated) |
