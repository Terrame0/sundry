# sundry

A utility Nix library (`sundry.*`), assembled from files under `src/` (the file's directory path becomes its `sundry.*` namespace).

## Before working, read the relevant doc in `.agent-docs/`

- [data-model.md](.agent-docs/data-model.md) — the VFS node (leaf vs. directory, `text`/`src`/`tags`) and path (segment list) shapes.
- [module-layout.md](.agent-docs/module-layout.md) — where a file goes, how it maps to `sundry.*`, when to split vs. keep together.
- [testing.md](.agent-docs/testing.md) — test format (`tests = [ [ actual expected ] ]`), run with `bash eval-result.sh`.
- [test-naming.md](.agent-docs/test-naming.md) — naming conventions for test fixtures.
- [docs-style.md](.agent-docs/docs-style.md) — how to write the docs themselves.

When you add, rename, or remove a doc under `.agent-docs/`, update this index in the same change so it never drifts from what's on disk.

@.agent-docs/docs-style.md
