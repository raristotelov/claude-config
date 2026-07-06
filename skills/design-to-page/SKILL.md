---
name: design-to-page
description: "Automates the build-test-review stages of the Figma-to-page workflow. Trigger ONLY after the design and spec are done and you have approved them. Invoke with /design-to-page (optionally name the page/spec). Runs developer -> qa -> reviewer, gating each stage."
argument-hint: "[page-or-spec name]"
---

# Design-to-Page Orchestrator

You orchestrate the MECHANICAL stages only: implement, test, review. The human
stages before this (designing the Figma frames and discussing/writing the spec)
are done interactively with the user and are NOT your job. You start only after
the user has approved the spec.

## Preconditions (verify before doing anything)
- A feature spec exists in `docs/features/` for `$ARGUMENTS`, with Status set to
  approved/`In Development`, and it contains the Figma frame node-ids (recorded
  by the main session during design).
- The Figma MCP is connected (the developer reads frames for fidelity).

If the spec is missing, not approved, or has no node-ids: STOP and tell the user.
Do NOT guess or invent a spec. Do NOT design or write the spec yourself.

## Sequence

1. **Implement.** Dispatch `senior-developer` to build the page(s) from the spec.
   It reads the frame(s) via the Figma MCP using the node-ids in the spec for
   visual fidelity, and follows project conventions (App Router, TypeScript,
   SASS modules, design system: #0055FF, #0A0F1C, Sora + JetBrains Mono).
   It reports the files created/modified.

2. **Test.** Dispatch `qa-engineer` to write and run tests against the spec's
   acceptance criteria and the implementation. If tests fail, route the failures
   back to `senior-developer`, then re-run `qa-engineer`. Loop until green
   (cap 3 attempts, then surface to the user).

3. **Review.** Dispatch `code-reviewer` as the final gate — reviews against the
   spec and conventions with tests already green. On critical/blocking findings,
   route back to `senior-developer` and re-run from step 2.

4. **Done.** When the review passes, mark the spec Status `Complete` and give the
   user a one-line summary: pages built, test results, review outcome.

## Rules
- Never skip a gate. Each stage starts only when the prior one's output allows.
- Every agent must describe any permission-requiring action before doing it
  (per global rules). Never run agents in bypass-permissions mode.
- Hand off concrete pointers via `docs/` and the spec (node-ids, file paths,
  failure notes) — don't assume one agent sees another's context.
- One line per stage transition. No play-by-play.
