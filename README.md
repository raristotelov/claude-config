# claude-marketplace

Personal Claude Code marketplace — agentic workflows and shared agents for
full-stack development. One repo, one plugin (`dev-workflows`), many orchestrator
skills over a shared agent pool.

## Install (per machine)

```
/plugin marketplace add raristotelov/claude-marketplace
/plugin install dev-workflows@claude-marketplace
/reload-plugins
```

Works the same on macOS and Linux (global scope). On Windows, run inside WSL2.

## Update after pushing changes

Auto-update is unreliable, so update manually. After you push edits to this repo:

```
/plugin marketplace update claude-marketplace
/reload-plugins
```

Bump the `version` in **both** `plugins/dev-workflows/.claude-plugin/plugin.json`
and `.claude-plugin/marketplace.json` on each meaningful change — the version
comparison is what triggers the update.

If it still reports "already at latest" (a known cache bug), force a refresh:

```
/plugin uninstall dev-workflows@claude-marketplace
/plugin install dev-workflows@claude-marketplace
/reload-plugins
```

## What's inside

See `plugins/dev-workflows/README.md` for the workflows and agents.

## peon-ping (notification sounds)

A `SessionStart` hook (`plugins/dev-workflows/hooks/peon-ping-install.sh`) checks
for [peon-ping](https://www.peonping.com/) and installs it if missing (Homebrew
or curl, once per machine). peon-ping is a separate tool with its own hooks that
fire on the same Claude Code events these workflows use, so completion sounds
just work. Delete the hook if you'd rather install it by hand.

## Figma seat note

The Figma-to-page workflow needs the Figma MCP connected with a Full seat for
write-to-canvas (Dev seat = drafts only). Run the Figma `whoami` tool to confirm
your seat.

## Notes

- MCP auth (Figma etc.) is per-machine OAuth — nothing sensitive is stored in
  this repo. Don't commit tokens; see `.gitignore`.
