# claude-config

My global Claude Code configuration — one source of truth, applied to any
machine. Ships `CLAUDE.md`, `settings.json`, agents, workflow skills, and the
peon-ping sound config.

## New machine (one-time)

```bash
git clone git@github.com:raristotelov/claude-config.git ~/.claude-config
~/.claude-config/claude-sync.sh bootstrap
```

That clones the repo, copies everything into `~/.claude/`, rewrites the
settings paths to this machine's home, and installs peon-ping if missing.
Restart Claude Code after.

## Everyday use

```bash
~/.claude-config/claude-sync.sh sync        # pull latest + apply
~/.claude-config/claude-sync.sh save "msg"  # push local ~/.claude edits back
```

Optional convenience — wrap Claude so it syncs automatically. Add to your
shell rc (`~/.zshrc` / `~/.bashrc`):

```bash
claude() {
  ~/.claude-config/claude-sync.sh sync >/dev/null 2>&1
  command claude "$@"
  ~/.claude-config/claude-sync.sh save >/dev/null 2>&1
}
```

## What's inside

```
CLAUDE.md                 Global rules (loaded every session)
settings.json             Hooks + config (paths use __CLAUDE_HOME__ placeholder)
agents/                   senior-architect-planner, product-docs-manager,
                          senior-developer, qa-engineer, code-reviewer
skills/                   design-to-page, feature-from-spec, design-generation
hooks/peon-ping-config.json   Bundled peon-ping settings (peon pack, vol 0.5)
claude-sync.sh            bootstrap | sync | save
```

## Notes

- The repo is the source of truth. `~/.claude/` is where it gets applied — it is
  NOT a git repo itself, so you never clone or pull inside it.
- `settings.json` stores paths as `__CLAUDE_HOME__`; the sync script swaps this
  for the real home on apply, and back to the placeholder on save. This is what
  makes it portable across Mac (`/Users/...`) and Linux (`/home/...`).
- peon-ping's runtime files (sounds, scripts) are NOT versioned — only your
  config is. The installer provides the binaries; your config sets the pack.
- Secrets and machine-specific state are gitignored. MCP auth (Figma etc.) is
  per-machine OAuth and never stored here.
- Agent memory is intentionally NOT in this repo (contains project-specific and
  sensitive notes). It rebuilds per machine, or sync it via a separate private
  repo if you want it to travel.

## Workflows

- `/design-to-page [page]` — Figma frame → spec → implement → test → review
- `/feature-from-spec [feature]` — architect → spec → implement → test → review
- `/design-generation` — design-phase playbook (records Figma node-ids)

Known gap: `senior-developer` needs `mcp__figma__get_design_context` added to
its tools for the Figma step. Agent memory paths inside the agent files are
still hardcoded to `/home/ubuntu/...` — make portable before relying on memory.
