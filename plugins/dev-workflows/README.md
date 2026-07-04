# dev-workflows

Multi-agent development workflows over a shared pool of specialist agents.
Each **skill** is one workflow (an orchestrator); all skills share the same
agents underneath.

## Workflows (skills)

- `/dev-workflows:design-to-page [page]` — Figma frame → spec → implement → test → review
- `/dev-workflows:feature-from-spec [feature]` — architect → spec → implement → test → review (no Figma)
- `/dev-workflows:design-generation` — playbook for the design phase (records node-ids)

## Shared agents

- `senior-architect-planner` — architecture, schema, task breakdown (opus)
- `product-docs-manager` — feature specs & acceptance criteria in `docs/`
- `senior-developer` — implements from specs
- `qa-engineer` — writes and runs tests
- `code-reviewer` — final-gate review

Add a new workflow = drop a new `skills/<name>/SKILL.md` that sequences these
agents differently. Nothing else changes.

## Handoff

Agents coordinate through the `docs/` folder (specs carry a Status field) rather
than passing context directly — each agent runs in its own context and only
returns a final message, so durable pointers live on disk.

## Known gaps (to fix)

- `senior-developer` has no Figma read tool. For `design-to-page` to implement
  directly from a frame, add `mcp__figma__get_design_context` to its `tools`.
- Agent memory paths in the agent files are hardcoded to `/home/ubuntu/...`.
  Make them portable before relying on memory across Mac/Linux.
