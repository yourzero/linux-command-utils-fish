#!/bin/bash
# install.sh — Install fish quick-command functions
#
# Usage:
#   ./install.sh                      # auto-detect tarball; download from GitHub if missing
#   ./install.sh /path/to/fish-functions.tar.gz

set -euo pipefail

GITHUB_USER="yourzero"
GITHUB_REPO="linux-command-utils-fish"
GITHUB_BRANCH="main"
GITHUB_RAW="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH"

TARBALL_NAME="fish-functions.tar.gz"
SUGGEST_NAME="__q_suggest.fish"
FISH_FUNCTIONS="$HOME/.config/fish/functions"
FISH_COMPLETIONS="$HOME/.config/fish/completions"
FISH_CONFIG="$HOME/.config/fish/config.fish"

# ─────────────────────────────────────────────────────────────────────────────

say()  { echo "  $*"; }
ok()   { echo "  ✓ $*"; }
warn() { echo "  ! $*"; }
ask()  { read -rp "  $1 [y/N] " _ans; [[ "$_ans" =~ ^[Yy]$ ]]; }

# Verify fish is installed
if ! command -v fish &>/dev/null; then
    echo "ERROR: fish is not installed. Install it first: https://fishshell.com"
    exit 1
fi

echo
echo "── linux-command-utils-fish installer ───────────────────────────────────"
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
    TMP_TAR="$(mktemp)"
    if curl -fsSL "$GITHUB_RAW/$TARBALL_NAME" -o "$TMP_TAR"; then
        TARBALL="$TMP_TAR"
        ok "Downloaded $TARBALL_NAME"
    else
        echo
        echo "ERROR: Could not download from $GITHUB_RAW/$TARBALL_NAME"
        exit 1
    fi
fi

say "Tarball: $TARBALL"

# ── Install q-functions ───────────────────────────────────────────────────────
echo
say "Installing q-functions to $FISH_FUNCTIONS ..."
mkdir -p "$FISH_FUNCTIONS" "$FISH_COMPLETIONS"
TMP_EXTRACT="$(mktemp -d)"
tar -xzf "$TARBALL" -C "$TMP_EXTRACT"
cp "$TMP_EXTRACT"/fish-functions/*.fish "$FISH_FUNCTIONS/"
if [[ -d "$TMP_EXTRACT/completions" ]]; then
    cp "$TMP_EXTRACT"/completions/*.fish "$FISH_COMPLETIONS/"
fi
rm -rf "$TMP_EXTRACT"
ok "$(ls "$FISH_FUNCTIONS"/q*.fish 2>/dev/null | wc -l | tr -d ' ') q-functions installed"
ok "Tab-completion for 'q <category>' installed"

# ── Optional: qcheatsheet at login ───────────────────────────────────────────
echo
if ask "Run qcheatsheet at every fish login?"; then
    mkdir -p "$(dirname "$FISH_CONFIG")"
    touch "$FISH_CONFIG"
    if grep -q 'qcheatsheet' "$FISH_CONFIG" 2>/dev/null; then
        ok "qcheatsheet login hook already present — skipped"
    else
        cat >> "$FISH_CONFIG" <<'EOF'

if status is-login
    qcheatsheet
end
EOF
        ok "Added qcheatsheet login hook to $FISH_CONFIG"
    fi
fi

# ── Optional: __q_suggest ─────────────────────────────────────────────────────
echo
if ask "Enable command suggestions (suggests q-commands after raw commands)?"; then
    SUGGEST_SRC=""

    if [[ -f "$SCRIPT_DIR/$SUGGEST_NAME" ]]; then
        SUGGEST_SRC="$SCRIPT_DIR/$SUGGEST_NAME"
    else
        say "$SUGGEST_NAME not found locally — downloading from GitHub..."
        TMP_SUGGEST="$(mktemp)"
        if curl -fsSL "$GITHUB_RAW/$SUGGEST_NAME" -o "$TMP_SUGGEST"; then
            SUGGEST_SRC="$TMP_SUGGEST"
            ok "Downloaded $SUGGEST_NAME"
        else
            warn "Could not download $SUGGEST_NAME — skipping suggestion feature"
        fi
    fi

    if [[ -n "$SUGGEST_SRC" ]]; then
        cp "$SUGGEST_SRC" "$FISH_FUNCTIONS/$SUGGEST_NAME"
        ok "Installed $SUGGEST_NAME"
    fi
fi

echo
echo "── Done ─────────────────────────────────────────────────────────────────"
echo
fish -c "qcheatsheet"
echo
echo "  All commands support -h for usage help."
echo
