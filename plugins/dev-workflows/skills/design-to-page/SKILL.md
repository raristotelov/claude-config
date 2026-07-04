---
name: design-to-page
description: "Orchestrates the Figma-to-page workflow. Trigger after the design phase to take approved Figma frames through spec, implementation, testing, and review. Invoke with /dev-workflows:design-to-page."
argument-hint: "[page-or-section name]"
---

# Design-to-Page Orchestrator

You are the orchestrator for turning approved Figma frames into shipped Next.js
pages. You do NOT write specs, code, tests, or reviews yourself — you dispatch
the specialist agents in order and gate each stage. The shared handoff surface
is the `docs/` folder (specs with a Status field), consistent with how these
agents already coordinate.

## Preconditions
- The design phase is complete (see the `design-generation` skill). Frames exist
  in Figma and their node-ids are recorded (in the relevant `docs/features/*.md`
  spec or a `.workflow/manifest.json`, whichever the design phase used).
- The Figma MCP is connected so the developer can read frames.

> KNOWN GAP (fix later): `senior-developer` currently has no Figma read tool in
> its `tools` list. To let it implement directly from a frame, add
> `mcp__figma__get_design_context` to that agent. Until then, the
> `product-docs-manager` captures the frame into a spec and the developer builds
> from the spec.

## Sequence

1. **Spec.** Dispatch `product-docs-manager` to read the frame(s) for
   `$ARGUMENTS` and produce/refresh the feature spec in `docs/features/`, with
   acceptance criteria. Set the spec Status to `In Development` when ready.

2. **Implement.** Dispatch `senior-developer` to build the page(s) from the spec,
   following project conventions (App Router, TypeScript, SASS modules,
   design system: #0055FF, #0A0F1C, Sora + JetBrains Mono). It reports the files
   created/modified.

3. **Test.** Dispatch `qa-engineer` to write and run tests against the spec's
   acceptance criteria and the implementation. If tests fail, route the failures
   back to `senior-developer`, then re-run `qa-engineer`. Loop until green
   (cap 3 attempts, then surface to the user).

4. **Review.** Dispatch `code-reviewer` as the final gate — it reviews against
   the spec and conventions with tests already green. On critical/blocking
   findings, route back to `senior-developer` and re-run from step 3.

5. **Done.** When the review passes, mark the spec Status `Complete` and give the
   user a one-line summary: pages built, test results, review outcome.

## Rules
- Never skip a gate. A stage starts only when the prior stage's output says so.
- Pass concrete pointers between stages via `docs/` (spec path, node-ids,
  file paths, failure notes) — don't assume one agent sees another's context.
- One line per stage transition. No play-by-play.
