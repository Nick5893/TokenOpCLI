#!/bin/sh
# tokenop installer — the Token Op Arcade.
#
#   curl -fsSL https://tokenop.dev/install.sh | sh
#   # or, before tokenop.dev is live:
#   curl -fsSL https://raw.githubusercontent.com/Nick5893/TokenOpCLI/main/install.sh | sh
#
# Works two ways:
#   * piped via curl  -> downloads the `tokenop` script from GitHub
#   * `sh install.sh` after a git clone -> installs the local copy
#
# Env knobs:
#   TOKENOP_BIN_DIR=/somewhere   install location (default ~/.local/bin)
#   TOKENOP_NO_ENABLE=1          install only; don't add the Claude Code hooks
#   sh install.sh --uninstall    remove the binary + disable hooks
set -eu

RAW="https://raw.githubusercontent.com/Nick5893/TokenOpCLI/main"
BIN_DIR="${TOKENOP_BIN_DIR:-$HOME/.local/bin}"
DEST="$BIN_DIR/tokenop"

say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# --- uninstall ------------------------------------------------------------- #
if [ "${1:-}" = "--uninstall" ]; then
  [ -x "$DEST" ] && "$DEST" disable >/dev/null 2>&1 || true
  rm -f "$DEST"
  say "Removed $DEST and disabled tokenop hooks (config/scores left intact)."
  exit 0
fi

say ""
say "  ▟█▙  tokenop — the Token Op Arcade"
say ""

# --- requirements ---------------------------------------------------------- #
command -v python3 >/dev/null 2>&1 || die "python3 is required (https://www.python.org/downloads/)."
case "$(uname -s 2>/dev/null || echo unknown)" in
  Darwin) : ;;
  *) say "  note: the auto-open window targets macOS + Terminal.app; games still play anywhere." ;;
esac

# --- fetch the tokenop script (local copy if present, else download) ------- #
mkdir -p "$BIN_DIR"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0" 2>/dev/null || echo .)" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/tokenop" ]; then
  say "==> Installing tokenop (local checkout)"
  cp "$SCRIPT_DIR/tokenop" "$DEST"
else
  say "==> Downloading tokenop"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW/tokenop" -o "$DEST" || die "download failed ($RAW/tokenop)"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$DEST" "$RAW/tokenop" || die "download failed ($RAW/tokenop)"
  else
    die "need curl or wget to download tokenop"
  fi
fi
chmod +x "$DEST"
say "    installed to $DEST"

# --- self-test (never enable a broken build) ------------------------------- #
say "==> Self-test"
if ! "$DEST" selftest >/dev/null 2>&1; then
  "$DEST" selftest || true
  die "self-test failed — not enabling hooks."
fi
say "    ok"

# --- enable the Claude Code hooks (opt out with TOKENOP_NO_ENABLE=1) -------- #
if [ "${TOKENOP_NO_ENABLE:-0}" = "1" ]; then
  say "==> Skipping hook setup (TOKENOP_NO_ENABLE=1). Run 'tokenop enable' when ready."
else
  say "==> Enabling Claude Code hooks (reversible with 'tokenop disable')"
  "$DEST" enable >/dev/null 2>&1 || say "    (could not edit ~/.claude/settings.json — run 'tokenop enable' manually)"
fi

# --- PATH check ------------------------------------------------------------ #
case ":${PATH:-}:" in
  *":$BIN_DIR:"*) ON_PATH=1 ;;
  *) ON_PATH=0 ;;
esac

say ""
say "Done. Welcome to the Token Op Arcade."
say ""
if [ "$ON_PATH" = "0" ]; then
  say "  $BIN_DIR isn't on your PATH yet. Add this to your shell rc:"
  say "      export PATH=\"\$HOME/.local/bin:\$PATH\""
  say "  then open a new shell, or run with the full path: $DEST"
  say ""
fi
say "  tokenop                 open the game selector"
say "  tokenop play pong       play a game (dino | snake | pong | flappy)"
say "  tokenop disable         turn off auto-open"
say ""
