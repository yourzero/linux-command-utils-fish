#!/bin/bash
# install.sh — Install fish quick-command functions on Unraid
#
# Usage:
#   ./install.sh                      # auto-detect tarball; download from GitHub if missing
#   ./install.sh /path/to/fish-functions.tar.gz
#
# What it does:
#   1. Installs 71 q-command fish functions to /boot/config/fish/functions/
#   2. Optionally adds qcheatsheet to fish login (via /boot/config/fish/config.fish)
#   3. Optionally installs __q_suggest (suggests q-commands after raw commands)
#   4. Syncs everything to the live /root/.config/fish/ for the current session

set -euo pipefail

# ── Config — update GITHUB_REPO before pushing to GitHub ─────────────────────
GITHUB_USER="yourzero"
GITHUB_REPO="linux-command-utils-fish"
GITHUB_BRANCH="main"
GITHUB_RAW="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH"

TARBALL_NAME="fish-functions.tar.gz"
SUGGEST_NAME="__q_suggest.fish"
BOOT_FISH="/boot/config/fish"
LIVE_FISH="/root/.config/fish"

# ─────────────────────────────────────────────────────────────────────────────

say()  { echo "  $*"; }
ok()   { echo "  ✓ $*"; }
warn() { echo "  ! $*"; }
ask()  { read -rp "  $1 [y/N] " _ans; [[ "$_ans" =~ ^[Yy]$ ]]; }

echo
echo "── fish-utils installer ─────────────────────────────────────────────────"
echo

# ── Resolve tarball ───────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARBALL="${1:-}"

if [[ -n "$TARBALL" && ! -f "$TARBALL" ]]; then
    warn "Provided tarball not found: $TARBALL"
    TARBALL=""
fi

if [[ -z "$TARBALL" && -f "$SCRIPT_DIR/$TARBALL_NAME" ]]; then
    TARBALL="$SCRIPT_DIR/$TARBALL_NAME"
fi

if [[ -z "$TARBALL" ]]; then
    say "Tarball not found locally — downloading from GitHub..."
    TMP_TAR="$(mktemp /tmp/fish-functions.XXXXXX.tar.gz)"
    if curl -fsSL "$GITHUB_RAW/$TARBALL_NAME" -o "$TMP_TAR"; then
        TARBALL="$TMP_TAR"
        ok "Downloaded $TARBALL_NAME"
    else
        echo
        echo "ERROR: Could not download from $GITHUB_RAW/$TARBALL_NAME"
        echo "  Either pass the tarball path as an argument, or set GITHUB_USER at the"
        echo "  top of this script to match your repository."
        exit 1
    fi
fi

say "Tarball: $TARBALL"

# ── Install q-functions ───────────────────────────────────────────────────────
echo
say "Installing q-functions to $BOOT_FISH/functions/ ..."
mkdir -p "$BOOT_FISH/functions"
tar -xzf "$TARBALL" --strip-components=1 -C "$BOOT_FISH/functions/"
ok "$(ls "$BOOT_FISH/functions/q"*.fish 2>/dev/null | wc -l) q-functions installed"

# ── Optional: qcheatsheet at login ───────────────────────────────────────────
echo
if ask "Run qcheatsheet at every fish login (SSH + console)?"; then
    touch "$BOOT_FISH/config.fish"
    if grep -q 'qcheatsheet' "$BOOT_FISH/config.fish" 2>/dev/null; then
        ok "qcheatsheet login hook already present — skipped"
    else
        cat >> "$BOOT_FISH/config.fish" <<'EOF'

if status is-login
    qcheatsheet
end
EOF
        ok "Added qcheatsheet login hook to $BOOT_FISH/config.fish"
    fi
fi

# ── Optional: __q_suggest ─────────────────────────────────────────────────────
echo
if ask "Enable command suggestions (suggests q-commands after raw commands)?"; then
    SUGGEST_SRC=""

    if [[ -f "$SCRIPT_DIR/$SUGGEST_NAME" ]]; then
        SUGGEST_SRC="$SCRIPT_DIR/$SUGGEST_NAME"
    else
        say "__q_suggest.fish not found locally — downloading from GitHub..."
        TMP_SUGGEST="$(mktemp /tmp/__q_suggest.XXXXXX.fish)"
        if curl -fsSL "$GITHUB_RAW/$SUGGEST_NAME" -o "$TMP_SUGGEST"; then
            SUGGEST_SRC="$TMP_SUGGEST"
            ok "Downloaded $SUGGEST_NAME"
        else
            warn "Could not download $SUGGEST_NAME — skipping suggestion feature"
        fi
    fi

    if [[ -n "$SUGGEST_SRC" ]]; then
        cp "$SUGGEST_SRC" "$BOOT_FISH/functions/$SUGGEST_NAME"
        ok "Installed $SUGGEST_NAME"
    fi
fi

# ── Sync to live session ──────────────────────────────────────────────────────
echo
say "Syncing to live session ($LIVE_FISH) ..."
mkdir -p "$LIVE_FISH/functions"
cp -f "$BOOT_FISH/functions/"*.fish "$LIVE_FISH/functions/"
[[ -f "$BOOT_FISH/config.fish" ]] && cp -f "$BOOT_FISH/config.fish" "$LIVE_FISH/config.fish"
ok "Live session updated"

echo
echo "── Done ─────────────────────────────────────────────────────────────────"
echo
echo "  Run 'qcheatsheet' to see all available commands."
echo "  To verify persistence: reboot mc-nas during a maintenance window,"
echo "  then run 'qhelp' in a new fish shell."
echo
