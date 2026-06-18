# Writing docs

Meta-rules for files under `.agent-docs/`.

## One topic per file

A doc owns one orthogonal concern — naming, layout, testing, etc. If you find yourself drafting an "extension", "appendix", or "see also at the end" section that doesn't fit the doc's main thread, the doc is probably two topics. Split it and link between them.

## No internal forward/backward references

Avoid pointers like *"see X at the end"* or *"as covered above"* within a single doc. They betray that the doc was added to over time and force the reader to skip around. Restructure so the natural reading order makes them unnecessary — either move the relevant content next to the reference, or split into a separate doc and link to it as a peer.

Cross-doc links are fine — they describe parallel concerns, not iteration history.

## Lead with the rule, not the history

A reader looking up "how do I name X" doesn't need to know which refactor produced the convention. State the rule, give an example, move on. Motivation goes in one line if it's not obvious, and only when it changes behavior at the edges.

## Concrete examples beat abstract rules

When a convention applies in multiple contexts, show one concrete example per context — don't substitute generalized prose. A reader skimming for "does this apply to my case" needs to recognize the shape, not parse abstractions.

Linked references (`[src/foo/bar.nix](../src/foo/bar.nix)`) are stronger than inline quotations: they survive code edits when prose drifts. Prefer them.

## Keep it scannable

- Tables for orthogonal axes (role × symbol, file × namespace).
- Code blocks for examples that should be visually pattern-matched or copy-pasted.
- Short paragraphs between them. If a paragraph reaches 4+ sentences, consider whether it could be a list.

## Avoid drift between docs and code

**A code change is not finished until the docs it contradicts are fixed in the same change.** Whenever you rename, move, remove, or repurpose anything a doc describes — a file path, function name, namespace, field name, or documented behavior — update the affected docs alongside the code, never as a follow-up. Find what's affected by grepping `.agent-docs/` for the old name *and* by re-reading any doc that links into the files you touched.

Cite files by linked path, never by name alone. A broken link rots loudly the first time someone navigates it; an unlinked name rots silently. When you rename or remove a file, grep `.agent-docs/` for references.

## Read it as a stranger

Before merging a doc change, re-read the file top-to-bottom. If any sentence makes sense only because *you* remember the conversation that produced it, rewrite it for someone who doesn't.
