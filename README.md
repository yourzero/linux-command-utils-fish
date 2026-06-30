# fish-utils

71 fish shell quick-command functions for Unraid, covering GPU monitoring, Docker, networking, disk, git, logs, services, and more. All functions follow a `q<name>` naming convention and support `-h` for usage help.

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/yourzero/fish-utils/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/yourzero/fish-utils.git
cd fish-utils && ./install.sh
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

## Unraid persistence

Unraid's root filesystem is a RAM disk rebuilt on every boot. This installer writes functions to `/boot/config/fish/functions/` (on the flash drive) and relies on the existing `/boot/config/go` hook to copy them into place at boot. No changes to `go` are required if the fish config copy block is already present.

## Requirements

- [fish shell](https://fishshell.com/) installed on the host (version 3.x)
- Unraid 6.x or later (or any Linux system with `/boot/config/fish/` configured as a persistent fish config source)

## All commands support `-h`

```
$ qdf -h
Usage: qdf [path]
  Human-readable df, filtered/sorted. Default path = /
```
# linux-command-utils-fish
# linux-command-utils-fish
