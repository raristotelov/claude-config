---
name: design-generation
description: "Playbook for the design phase. Use when creating or iterating on Figma frames in the main session, so node-ids and status are recorded consistently for the design-to-page workflow."
---

# Design Generation

This governs the design phase, which happens in the main session (a conversation
with the user), NOT in an agent. Designing is a back-and-forth; agents are for
the non-conversational stages that come after.

## While designing
- **Read the project's own design system before drawing anything** — look for
  `docs/design-system.md` / `docs/style-guide.md`, then the existing Figma file,
  then the client CSS. Never assume tokens from another project. If none exists,
  derive tokens from the code and ask the user to confirm them.
- Reuse existing components rather than drawing new ones.
- Each time you create a frame, immediately record its name, Figma URL, and
  node-id. The Figma write tools return the node-id on creation — capture it
  then, don't rediscover it later. Record either in the feature spec under
  `docs/features/` or in `.workflow/manifest.json`.

## File structure

- One page per breakpoint plus a components page: **Desktop**, **Tablet**, **Mobile**, **Components**.
- Within a breakpoint page, one **section per flow** (Auth, Popular, Feed, Profile…), laid left to right.
- Within a section, the base view first and its **states stacked vertically** beneath it (empty state, other-user, popups, scrolled…).
- Use the same section names and the same left-to-right order on every breakpoint page, so the pages mirror each other.
- Keep spacing uniform: 200px between frames in a column, 400px between sections, 80px section padding.
- Set every page canvas background and every section fill to **#1e1e1e** — that is the background we use. Figma defaults each new section to white and each page to #F5F5F5; both are wrong, so set them explicitly.
- Name frames by view and state — `Profile View – Other User`, `Feed View – Comments`. Suffix the breakpoint where it isn't the page default.
- Components live on the Components page, never among the screens.

## Breakpoints

- Design three widths: desktop, tablet portrait, mobile. Landscape tablet falls under the desktop rules — it needs no frames of its own.
- Think in widths, not devices. A tablet in landscape is the same as a resized desktop window.
- Check the chrome actually fits before assuming a layout carries over; measure the header contents against the frame width.

## Components and sharing

- Share components across **views within a breakpoint** — that's what stops ten copies of a header drifting apart.
- Do **not** share chrome (headers, nav bars, tab bars) **across breakpoints**. Their constraints genuinely differ, and fixing one width will break another.
- Small building blocks — buttons, inputs, cards, avatars, tiles — may be shared across breakpoints, but only if built to resize: auto-layout with fill/hug rather than absolute positions and fixed text widths.
- **Before changing any shared component, work out what else uses it.** If the change would affect another breakpoint or a view the user considers finished, stop and tell them what would change, and agree whether to edit in place or make a separate copy for that screen. Never silently alter a signed-off screen.

## Capturing an existing app

- When the design already exists as code, measure the **rendered DOM**
  (`getBoundingClientRect`, computed styles) rather than reading values off a
  screenshot. Screenshots lie about spacing.
- Separate design intent from implementation accidents. Leftover debug styles,
  margins that only exist because of a stray `margin: 5px`, or an asset that was
  drawn inverted are bugs to fix, not conventions to reproduce. Say which you
  think each one is.
- Once the design intentionally diverges from the app, **record every deviation
  in one place** (a task in the TODO, or the design system doc) with the reason.
  These accumulate fast and are otherwise lost in conversation.

## Dark mode

Optional — agree per project whether it's in scope. When it is, this is the method.

1. **Create a colour variable collection with Light and Dark modes** before drawing
   anything dark. Name tokens by role, not appearance: `background/page`,
   `text/primary`, `border/card`.
2. **Validate the palette on one real screen first.** Recolour a single frame and
   look at it — nobody can judge a dark palette from hex values. Only commit to
   the token work once it's approved.
3. **Bind every fill and stroke to a token.** Walk the file and replace raw
   paints with bound ones. Text with mixed fills needs per-segment binding via
   `getStyledTextSegments` and `setRangeFills`, or captions silently keep their
   light colours.
4. **Split white into two tokens.** `background/surface` for cards and bars, and
   a `static/white` that stays white in both modes for content sitting *on* a
   colour or photo — button labels, counts over an image scrim. Binding both to
   surface turns that content near-black in dark mode. The same applies to any
   colour doing two jobs.
5. **Leave over-photo chrome untokenised.** Story viewers, image overlays and
   similar always sit on a photograph, so their white text and icons are fixed,
   not mode-dependent.
6. **Duplicate each section into `X — Light` and `X — Dark` rows**, and set the
   dark clone's mode with `setExplicitVariableModeForCollection`. Don't recolour
   the clone — the mode does it. Two visible rows beat a hidden toggle for
   review, at the cost of structural edits being made twice.
7. **Audit for unbound colours afterwards.** Anything still carrying raw hex
   won't respond to the mode and will look wrong in exactly one of them.

Note that dark mode often *improves* contrast: greys that fail AA on a light
background usually pass comfortably on a dark one. Re-check rather than assume.

## Content and states

- Use realistic content — real photographs, plausible counts and names. Grey
  placeholder boxes hide alignment, contrast and wrapping problems.
- Design the empty state as well as the populated one, and make it coherent: a
  brand-new account has no posts *and* no followers *and* no bio.
- Don't mirror every state across breakpoints without checking it exists there.
  Hover has no meaning on touch, and a dropdown needs a trigger that's actually
  present on that screen.
- States expressed only as variants aren't testable. Wire hover and click
  interactions in the prototype if the user needs to feel them.

## Verify, don't eyeball

- Measure spacing and alignment from actual node values rather than judging from a screenshot; optical gaps differ from raw spacing values when items carry internal padding.
- Check text contrast against WCAG AA before settling on a colour.
- Screenshot after each meaningful change — several bugs only show up rendered (clipped text, off-centre content, icons that don't scale).

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
