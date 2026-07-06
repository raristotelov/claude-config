---
name: design-generation
description: "Playbook for the design phase. Use when creating or iterating on Figma frames in the main session, so node-ids and status are recorded consistently for the design-to-page workflow."
---

# Design Generation

This governs the design phase, which happens in the main session (a conversation
with the user), NOT in an agent. Designing is a back-and-forth; agents are for
the non-conversational stages that come after.

## While designing
- Build frames in Figma to the design system: primary #0055FF, background
  #0A0F1C, fonts Sora + JetBrains Mono. Reuse existing components.
- Each time you create a frame, immediately record its name, Figma URL, and
  node-id. The Figma write tools return the node-id on creation — capture it
  then, don't rediscover it later. Record either in the feature spec under
  `docs/features/` or in `.workflow/manifest.json`.

## When the user says design is done
- Confirm every frame has a recorded node-id.
- Mark the design complete (spec Status `In Development`, or
  `design.status: "complete"` in the manifest).
- Tell the user it's marked complete and they can run
  `/dev-workflows:design-to-page <page-name>`.

## Don't
- Don't wrap the design in browser chrome (Safari/Chrome toolbar, traffic-light
  dots, URL bar, window frame). Design the page content only, starting at the
  site's own navbar.
- Don't implement code here — design only.
- Don't put node-ids or run status in CLAUDE.md; that's runtime state. It lives
  in the spec or the manifest.
