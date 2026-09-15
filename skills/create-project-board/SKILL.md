---
name: create-project-board
description: "Create a GitHub Projects v2 board for a repo, named '<repo> Board' with Status options Todo / In Progress / Done. Use when asked to create a project, board, or kanban for a repository."
---

# Create a project board

Projects v2 is GraphQL-only. The GitHub MCP server exposes no project tools, so every
step here uses `gh`. MCP is still the right tool for issues, PRs and repo contents.

## Naming

- Board title is the repo name in **Title Case with hyphens as spaces**, then `Board`:
  `assistant-console` → `Assistant Console Board`, `social-media-app` → `Social Media App
  Board`. Not the raw slug.
- Status options are exactly **`Todo`**, **`In Progress`**, **`Done`**, in that order.
  `Todo` is one word with no space: it is GitHub's own default on a new board and what
  every existing board uses, so `item-edit --value "Todo"` works everywhere. Do not
  "correct" it to `To Do`.

## Steps

1. Confirm the repo name and that no board already exists for it:

   ```
   gh project list --owner @me --format json
   ```

2. Create the board and keep the number it returns:

   ```
   gh project create --owner @me --title "<Title Case Repo> Board" --format json
   ```

3. Read the fields back — a new board may or may not ship a Status field:

   ```
   gh project field-list <number> --owner @me --format json
   ```

4. A new board ships a `Status` field already, with exactly `Todo, In Progress, Done` —
   so normally there is nothing to do here.

   Only if no `Status` field exists, create it:

   ```
   gh project field-create <number> --owner @me --name "Status" \
     --data-type "SINGLE_SELECT" --single-select-options "Todo,In Progress,Done"
   ```

   To change existing options, `gh` is no help — it cannot edit single-select options.
   That needs `updateProjectV2Field` over GraphQL, whose `singleSelectOptions` **replaces**
   the whole list and reissues option ids, which can clear the Status of items already on
   the board. Do it before adding items, and check with the user first.

5. Link the board to its repo. Projects v2 boards belong to the **owner account**, not a
   repo, so without this the repo's Projects tab looks empty and the user will think the
   board was never created:

   ```
   gh project link <number> --owner <login> --repo <owner>/<repo>
   ```

   Use the literal login, not `@me` — `@me` is rejected as "different owner" when the
   `--repo` is given in `owner/name` form. The command prints nothing on success.

6. Switch the default view to kanban. A new project opens as a **table**, not columns, so
   without this it looks nothing like the existing boards:

   ```
   gh api graphql -f query='query{user(login:"<login>"){projectV2(number:<number>)
     {views(first:1){nodes{id layout}}}}}'

   gh api graphql -f query='mutation($viewId:ID!){updateProjectV2View(
     input:{viewId:$viewId,layout:BOARD_LAYOUT}){projectV2View{layout}}}' \
     -F viewId=<view-id>
   ```

   `gh` has no command for views; this is GraphQL only.

7. Verify and report the board URL:

   ```
   gh api graphql -f query='query{repository(owner:"<owner>",name:"<repo>")
     {projectsV2(first:10){nodes{number title url}}}}'
   ```

## Adding issues later

A freshly added item has **no Status** until one is set explicitly — both steps are needed:

```
gh project item-add <number> --owner @me --url <issue-url>
gh project item-edit <number> --owner @me --url <issue-url> --field "Status" --value "Todo"
```

## Notes

- `item-add` and `item-edit` print nothing on success. Always verify with
  `gh project item-list <number> --owner @me --format json`.
- Target boards by number, never by title.
- Boards are per-owner, not per-repo; `--owner @me` puts them under the user's account.
