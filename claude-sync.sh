#!/usr/bin/env bash
#
# claude-sync.sh — ship your global Claude Code config to any machine.
#
#   bootstrap   First-time setup on a new machine: clone (if needed) + apply.
#   sync        Pull latest from GitHub and apply into ~/.claude.
#   save [msg]  Commit local ~/.claude changes back and push.
#
# The repo is the source of truth. `sync`/`bootstrap` copy repo -> ~/.claude and
# rewrite the settings.json path placeholder to this machine's home. peon-ping
# (the sound tool) is installed via its own installer if missing, then your
# bundled config is dropped in.
#
# Config lives in this repo. ~/.claude is the applied target (not a git repo).

set -euo pipefail

# --- config -----------------------------------------------------------------
REPO_URL="https://github.com/raristotelov/claude-config.git"
# The repo is the directory this script sits in (override with CLAUDE_CONFIG_REPO).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${CLAUDE_CONFIG_REPO:-$SCRIPT_DIR}"
CLAUDE_HOME="$HOME/.claude"
PLACEHOLDER="__CLAUDE_HOME__"

# Files/dirs this repo owns and applies into ~/.claude:
APPLY_ITEMS=("CLAUDE.md" "settings.json" "agents" "skills")

# MCP servers to register at user scope (name|transport|url).
# These are added via `claude mcp add` because Claude Code reads user-scope MCP
# from ~/.claude.json, not settings.json. Auth is still one-time per machine.
MCP_SERVERS=(
  "figma|http|https://mcp.figma.com/mcp"
)

# --- helpers ----------------------------------------------------------------
log() { printf '  %s\n' "$*"; }

ensure_repo() {
  if [ ! -d "$REPO_DIR/.git" ]; then
    log "Cloning config repo into $REPO_DIR"
    git clone "$REPO_URL" "$REPO_DIR"
  fi
}

apply_files() {
  mkdir -p "$CLAUDE_HOME"
  for item in "${APPLY_ITEMS[@]}"; do
    if [ -e "$REPO_DIR/$item" ]; then
      log "Applying $item"
      # -a preserve perms (keeps executable bits on any scripts); --delete keeps
      # dirs in sync. Files not owned by the repo (credentials, plugins, etc.)
      # are untouched because we only target APPLY_ITEMS.
      if [ -d "$REPO_DIR/$item" ]; then
        rsync -a --delete "$REPO_DIR/$item/" "$CLAUDE_HOME/$item/"
      else
        cp "$REPO_DIR/$item" "$CLAUDE_HOME/$item"
      fi
    fi
  done
}

rewrite_paths() {
  # Replace the placeholder in the applied settings.json with the real home.
  local target="$CLAUDE_HOME/settings.json"
  [ -f "$target" ] || return 0
  log "Rewriting settings paths -> $CLAUDE_HOME"
  # portable in-place sed (BSD/macOS + GNU/Linux)
  sed -i.bak "s#${PLACEHOLDER}#${CLAUDE_HOME}#g" "$target" && rm -f "$target.bak"
}

ensure_peon() {
  if [ ! -f "$CLAUDE_HOME/hooks/peon-ping/peon.sh" ]; then
    log "Installing peon-ping (missing)"
    if command -v brew >/dev/null 2>&1; then
      brew install PeonPing/tap/peon-ping >/dev/null 2>&1 || \
        curl -fsSL https://peonping.com/install | bash >/dev/null 2>&1 || \
        log "peon-ping install failed (optional) — skipping"
    else
      curl -fsSL https://peonping.com/install | bash >/dev/null 2>&1 || \
        log "peon-ping install failed (optional) — skipping"
    fi
  fi
  # Drop in your bundled config (pack choice, volume) over the default.
  if [ -f "$REPO_DIR/hooks/peon-ping-config.json" ] && \
     [ -d "$CLAUDE_HOME/hooks/peon-ping" ]; then
    log "Applying peon-ping config"
    cp "$REPO_DIR/hooks/peon-ping-config.json" \
       "$CLAUDE_HOME/hooks/peon-ping/config.json"
  fi
}

ensure_mcp() {
  command -v claude >/dev/null 2>&1 || { log "claude CLI not found — skipping MCP"; return 0; }
  local existing name transport url
  existing="$(claude mcp list 2>/dev/null || true)"
  for entry in "${MCP_SERVERS[@]}"; do
    name="${entry%%|*}"
    transport="${entry#*|}"; transport="${transport%%|*}"
    url="${entry##*|}"
    if printf '%s\n' "$existing" | grep -q "^${name}[:[:space:]]"; then
      continue
    fi
    log "Registering MCP server: $name"
    claude mcp add --scope user --transport "$transport" "$name" "$url" \
      >/dev/null 2>&1 || log "MCP add failed for $name — add manually"
  done
}

# --- commands ---------------------------------------------------------------
cmd_bootstrap() {
  ensure_repo
  apply_files
  rewrite_paths
  ensure_peon
  ensure_mcp
  log "Bootstrap complete. Restart Claude Code."
}

cmd_sync() {
  ensure_repo
  log "Pulling latest"
  git -C "$REPO_DIR" pull --ff-only
  apply_files
  rewrite_paths
  ensure_peon
  ensure_mcp
  log "Sync complete."
}

cmd_save() {
  ensure_repo
  local msg="${1:-sync from $(hostname) $(date +%F_%T)}"
  # Pull your live ~/.claude edits back into the repo before committing.
  for item in "${APPLY_ITEMS[@]}"; do
    if [ -e "$CLAUDE_HOME/$item" ]; then
      if [ -d "$CLAUDE_HOME/$item" ]; then
        rsync -a --delete "$CLAUDE_HOME/$item/" "$REPO_DIR/$item/"
      else
        cp "$CLAUDE_HOME/$item" "$REPO_DIR/$item"
      fi
    fi
  done
  # Re-insert the placeholder so the repo copy stays portable.
  if [ -f "$REPO_DIR/settings.json" ]; then
    sed -i.bak "s#${CLAUDE_HOME}#${PLACEHOLDER}#g" "$REPO_DIR/settings.json" \
      && rm -f "$REPO_DIR/settings.json.bak"
  fi
  git -C "$REPO_DIR" add -A
  if git -C "$REPO_DIR" diff --cached --quiet; then
    log "No changes to save."
  else
    git -C "$REPO_DIR" commit -m "$msg"
    git -C "$REPO_DIR" push
    log "Saved and pushed."
  fi
}

main() {
  case "${1:-}" in
    bootstrap) cmd_bootstrap ;;
    sync)      cmd_sync ;;
    save)      shift; cmd_save "${1:-}" ;;
    *)
      echo "Usage: claude-sync.sh {bootstrap|sync|save [message]}"
      exit 1
      ;;
  esac
}

main "$@"