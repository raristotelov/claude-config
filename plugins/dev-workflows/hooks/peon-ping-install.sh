#!/usr/bin/env bash
# Checks for peon-ping and installs it if missing. Mac + Linux.
# Runs at session start; stays quiet and never blocks the session.
# Remove this hook (or the plugin) if you don't want auto-install.

set -u

# Already installed? Do nothing.
if command -v peon >/dev/null 2>&1 || command -v peon-ping >/dev/null 2>&1; then
  exit 0
fi

# Only attempt once per machine — leave a marker so we don't retry every session.
MARKER="${HOME}/.claude/.peon-ping-install-attempted"
if [ -f "${MARKER}" ]; then
  exit 0
fi
mkdir -p "${HOME}/.claude" 2>/dev/null || true
touch "${MARKER}" 2>/dev/null || true

# Prefer Homebrew if present (Mac, or Linuxbrew).
if command -v brew >/dev/null 2>&1; then
  brew install peon-ping >/dev/null 2>&1 &
  exit 0
fi

# Otherwise fall back to the official curl installer.
if command -v curl >/dev/null 2>&1; then
  curl -fsSL https://www.peonping.com/install.sh | bash >/dev/null 2>&1 &
  exit 0
fi

# Couldn't install automatically — that's fine, it's optional.
exit 0
