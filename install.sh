#!/usr/bin/env bash
# install.sh — one-click installer for `tokenop`, the Token Op Arcade
# (a Claude Code spinner companion).
#
#   ./install.sh              copy tokenop to ~/.local/bin, selftest, enable, status
#   ./install.sh --uninstall  disable hooks + remove ~/.local/bin/tokenop
#
# Idempotent: re-running re-copies the binary and re-enables without creating
# duplicate PATH lines or duplicate hooks.
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/tokenop"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/tokenop"

# --------------------------------------------------------------------------- #
# Uninstall
# --------------------------------------------------------------------------- #
if [ "${1:-}" = "--uninstall" ]; then
  echo "==> Uninstalling tokenop"
  if [ -x "$DEST" ]; then
    "$DEST" disable || true
  fi
  rm -f "$DEST"
  echo "Removed: $DEST"
  echo "Removed tokenop hooks from Claude settings (if present)."
  echo
  echo "Your config, state, and high scores were left intact."
  echo "To purge them too:"
  echo "  rm -rf ~/.config/tokenop ~/.local/state/tokenop"
  exit 0
fi

# --------------------------------------------------------------------------- #
# Install
# --------------------------------------------------------------------------- #
if [ ! -f "$SRC" ]; then
  echo "error: cannot find tokenop at $SRC" >&2
  exit 1
fi

echo "==> Installing tokenop to $DEST"
mkdir -p "$BIN_DIR"
cp "$SRC" "$DEST"
chmod +x "$DEST"
echo "Copied and chmod +x."

# --------------------------------------------------------------------------- #
# PATH check (append to shell rc once, guarded by grep)
# --------------------------------------------------------------------------- #
case ":${PATH}:" in
  *":$BIN_DIR:"*)
    echo "PATH already includes $BIN_DIR."
    ;;
  *)
    RC=""
    if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "zsh" ]; then
      RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
      RC="$HOME/.bashrc"
    elif [ -f "$HOME/.profile" ]; then
      RC="$HOME/.profile"
    else
      RC="$HOME/.zshrc"
    fi
    LINE='export PATH="$HOME/.local/bin:$PATH"'
    touch "$RC"
    if grep -Fqs "$LINE" "$RC"; then
      echo "PATH line already present in $RC."
    else
      printf '\n# Added by tokenop install.sh\n%s\n' "$LINE" >>"$RC"
      echo "Appended PATH line to $RC."
    fi
    echo
    echo "WARNING: $BIN_DIR is not on your PATH yet."
    echo "         Open a new shell, or run:  source \"$RC\""
    ;;
esac

# --------------------------------------------------------------------------- #
# Selftest (abort if broken — never enable hooks on a bad build)
# --------------------------------------------------------------------------- #
echo
echo "==> Running selftest"
if ! "$DEST" selftest; then
  echo
  echo "error: selftest failed — not enabling hooks. See output above." >&2
  exit 1
fi

# --------------------------------------------------------------------------- #
# Enable hooks (default mode: every-prompt) + show status
# --------------------------------------------------------------------------- #
echo
echo "==> Enabling Claude Code hooks (mode: every-prompt)"
"$DEST" enable

echo
echo "==> Status"
"$DEST" status

# --------------------------------------------------------------------------- #
# Final tips
# --------------------------------------------------------------------------- #
cat <<EOF

==> Done. tokenop is installed — welcome to the Token Op Arcade.

Play now:
  tokenop                 open the menu (game selector)
  tokenop play snake      play a specific game (dino|snake|pong|flappy)

Change the pop-up game:
  tokenop set <game>      (or 'tokenop set menu' for the selector)

Switch modes:
  tokenop enable --mode session       # open on prompt; window stays open
  tokenop enable --mode every-prompt  # open on prompt, close on stop (default)

Uninstall:
  tokenop disable && rm -f "$DEST"
  # or: ./install.sh --uninstall
EOF
