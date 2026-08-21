---
name: create-ticket
description: "Writing rules and templates for task tickets — page implementation/redesign, minor improvement, and bug. Use whenever creating a new ticket or rewriting an existing ticket's description."
---

# Creating a ticket

## Procedure

1. Pick the template below by the kind of work. When in doubt between the page template and the improvement template, ask — the page one is for work with a design behind it, the improvement one for a small change.
2. Fill it in. **Verify every file path, line reference, component name and value against the codebase before writing it into a ticket.** Never invent a path or a hex value, and never carry one over from another project.
3. Create the issue **unassigned**. Assign only when work actually starts on it.
4. Put it on the project board in the first column (Todo). The board number and commands are in the project's own section of `CLAUDE.md`.
5. Verify by reading the state back. The project CLI prints nothing on success, so an empty response is not confirmation.

## Writing rules

- **Goal** takes the user story shape by default — `As a <user>, I want <capability>, so that <benefit>`. Use one plain sentence for tooling or cleanup work, where the "so that" would be filler.
- **Acceptance criteria** state what "correct" means for this particular ticket. Write conditions that can pass or fail ("the sign-up response contains no password hash"), not areas to go inspect ("check the sign-up response").
- **Tests** is the definition of done — the same items on every ticket. Treat them as boilerplate rather than something to rethink each time. Drop an item that genuinely doesn't apply, such as a server test on a CSS-only change.
- Tickets say what needs doing, nothing else. No "Out of scope", "Files in scope" or "Source" sections.
- **For a pure redesign, drop the Feature section.** Listing design deltas (border colours, padding values, tile sizes) duplicates the design file and drifts from it — the design *is* the spec. Keep Feature only when there is functional work or bug fixing alongside the redesign. Requirements that aren't visible in the design, such as a model-level field cap, belong in the acceptance criteria.
- **Page work covers every breakpoint** — desktop, tablet and mobile, in light and dark, and stays usable down to the project's minimum viewport width without horizontal scroll or clipped content. The project's section of `CLAUDE.md` records the actual widths and that floor.
- **Page work defines colours as CSS custom properties** rather than hardcoded hex, with a dark set alongside the light one. Keep the surface white and the content-on-colour white as **separate** variables — they are usually the same value in light mode, but only surface darkens. Binding both to surface turns button labels and other content-on-colour near-black in dark mode.
- Cypress specs are **written but never executed** — the user runs them.
- Skip the test items on bugs that aren't observable (dead code, unused variables, debug CSS).
- Record decisions the ticket can't settle — a ranking rule, an expiry mechanism — as work items, not as assumptions silently resolved.

## 1. Page implementation / redesign

```markdown
## Goal

As a <user>, I want <capability>, so that <benefit>.

## Design

Redesign <page / component> according to the designs: <figma-link>

Implement the desktop, tablet and mobile styles.

Define the page's colours as CSS custom properties rather than hardcoded hex values, with a dark set alongside the light one.

## Feature

<!-- Only when there is functional work or bug fixing alongside the redesign. Drop this section for a pure redesign. -->

- [ ] <behaviour to build>
- [ ] <behaviour to build>

## Acceptance criteria

- [ ] <condition that must hold>
- [ ] <failure path handled>

## Tests

- [ ] **Unit (client)** — React Testing Library + Jest, colocated with the component. Happy path, validation errors, request failure.
- [ ] **Unit (server)** — service-level behaviour.
- [ ] **Cypress** — e2e for the flow.
```

## 2. Improvement / minor feature

```markdown
## Goal

As a <user>, I want <capability>, so that <benefit>.

## Change

- [ ] <what changes>

## Acceptance criteria

- [ ] <condition that must hold>

## Tests

- [ ] **Unit** — React Testing Library + Jest, colocated with the component.
- [ ] **Cypress** — only if the change is a user-visible flow.
```

## 3. Bug

```markdown
## Problem

<what's wrong, with file:line>

## Steps to reproduce

1. <step>
2. <step>
3. <what you see>

## Expected

<what should happen instead>

## Fix

- [ ] <the change>

## Tests

- [ ] **Unit** — regression test that fails before the fix and passes after.
- [ ] **Cypress** — walk the reproduction steps, where the bug is reachable through the UI.
```
