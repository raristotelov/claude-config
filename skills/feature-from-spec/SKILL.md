---
name: feature-from-spec
description: "Orchestrates building a feature with no Figma design — architect plans, docs specs, dev implements, QA tests, reviewer gates. Invoke with /dev-workflows:feature-from-spec."
argument-hint: "[feature name or brief]"
---

# Feature-from-Spec Orchestrator

A workflow for features that don't start from a Figma design. Same shared agent
pool as `design-to-page`, different sequence — this is the point of one plugin
with many orchestrator skills.

## Sequence

1. **Plan.** Dispatch `senior-architect-planner` to design the architecture,
   schema, folder structure, and task breakdown for `$ARGUMENTS`. Output lands
   in `docs/` (decisions, requirements).

2. **Spec.** Dispatch `product-docs-manager` to turn the plan into feature
   spec(s) with acceptance criteria in `docs/features/`.

3. **Implement.** Dispatch `senior-developer` to build from the spec, following
   the architect's plan and project conventions.

4. **Test.** Dispatch `qa-engineer` to write/run tests against acceptance
   criteria. On failure, route back to `senior-developer`, re-run (cap 3).

5. **Review.** Dispatch `code-reviewer` as the final gate with tests green.
   On blocking findings, route back and re-run from step 4.

6. **Done.** Mark the spec `Complete`; one-line summary to the user.

## Rules
- Architecture is decided once here, up front — downstream agents follow it,
  they don't re-decide per task.
- Gate every stage. Hand off concrete pointers via `docs/`.
