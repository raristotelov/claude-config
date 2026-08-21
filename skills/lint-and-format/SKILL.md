---
name: lint-and-format
description: "How ESLint and Prettier are divided and configured, and the rules for keeping them from contradicting each other. Use when writing or changing lint/Prettier config, when a lint error looks like a tooling conflict, when tempted to suppress a rule, or when setting up a new project."
---

# Linting and formatting

## The division

**Prettier writes. ESLint checks.** Prettier rewrites every file on `format` and is the only thing that actually produces formatting on disk. ESLint reports.

Where both have an opinion on the same thing, they must be configured to agree exactly, because when they disagree Prettier always wins on disk and ESLint reports an error that can never be cleared.

## Never suppress

No `eslint-disable`, `eslint-disable-next-line`, `prettier-ignore`, `@ts-ignore`, or any equivalent. A lint error means the code is wrong or the rule is wrong.

- Code wrong → fix the code.
- Rule wrong → STOP, discuss it with the user, change the config so it applies everywhere.

Never decide this alone, and never patch it at the call site.

## Keeping the two in agreement

Every ESLint rule that overlaps a Prettier option must mirror it exactly. The pairs:

| ESLint rule | Prettier option |
|---|---|
| `semi` | `semi` |
| `quotes` | `singleQuote` |
| `jsx-quotes` | `jsxSingleQuote` |
| `comma-dangle` | `trailingComma` |
| `arrow-parens` | `arrowParens` |
| `max-len` | `printWidth` |
| `no-multiple-empty-lines` | collapses blank lines to 1 |

Three of these need options, or they diverge from Prettier no matter what value you pick:

- **`quotes` needs `avoidEscape: true`.** Prettier switches to double quotes when a string contains an apostrophe, to avoid escaping. Without this option ESLint rejects that and no formatting satisfies both.
- **`max-len` needs `ignoreStrings: true` and `ignoreTemplateLiterals: true`.** `printWidth` is a target Prettier wraps toward, not a ceiling — it cannot break an unbreakable token. A long SVG path or URL will always exceed the limit.
- **`indent` cannot be reconciled and must not be set.** ESLint's indent algorithm and Prettier's printer genuinely differ on nested constructs — JSX returned from a callback inside a ternary, chained calls. `useTabs` and `tabWidth` already guarantee the indentation; adding the ESLint rule only creates unfixable errors.

Rules with no Prettier counterpart are free to use — `react/jsx-newline`, `no-unused-vars`, `jsx-a11y/*`, the `react-app` preset. These are where ESLint earns its place: correctness, not formatting.

## Verifying a config

Do not reason about whether the two agree — test it. Pipe a candidate through both and compare:

```
printf "const a = \"it's fine\";\n" | npx eslint --stdin --stdin-filename src/probe.js
printf "const a = \"it's fine\";\n" | npx prettier --stdin-filepath src/probe.js
```

Cases worth probing: a string containing an apostrophe, a string over `printWidth`, a template literal over `printWidth`, and nested JSX inside a ternary.

## Definition of done

`format`, then `lint`, then tests — all clean, in every package. A change that has not been linted and formatted is not finished. Both packages must be configured the same way; a rule fixed in one and not the other is a latent failure.
