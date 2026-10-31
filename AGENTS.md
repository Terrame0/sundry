# sundry

A utility Nix library (`sundry.*`), assembled from files under `src/` where the file's directory path becomes its `sundry.*` namespace.

## Before working, read the relevant doc in `.agent-docs/`

- [data-model.md](.agent-docs/data-model.md) — the VFS node shapes (leaf vs. directory, the opaque/authored payload states, `text`/`origin`/`tag-list`) and path shapes (segment lists).
- [vfs-lifecycle.md](.agent-docs/vfs-lifecycle.md) — VFS constructors, opaque ingest, the `vfs.file.read`/`vfs.file.edit` split, and the tag-resolution, Nix-loading, and copy-or-write materialization stages.
- [tag-resolution.md](.agent-docs/tag-resolution.md) — how `{key:value}` annotations in path segments become cleaned paths and per-segment `tag-list` entries.
- [tag-matching.md](.agent-docs/tag-matching.md) — tag-spec query semantics, including `tag` concatenation, `deepest-tag` override, per-level position, and `boolean.expr` binding.
- [attrs-traversal.md](.agent-docs/attrs-traversal.md) — attrset traversal terminal-node semantics, the `halt`/`matches` axes, specialization matrix, and implementation dependencies.
- [attrs-merge.md](.agent-docs/attrs-merge.md) — attrset merge callback paths, resolver composition, and the VFS-aware `dirs` resolver.
- [attrs-validation.md](.agent-docs/attrs-validation.md) — asymmetric attrset comparison and the template DSL used by `attrs.validate`.
- [dependency-resolution.md](.agent-docs/dependency-resolution.md) — topological layers and lazy assembly of named transform results from declared dependencies.
- [python-script.md](.agent-docs/python-script.md) — `script.python` contract: the source root is the wheel root, why `only-include = ["."]`, how `entrypoint` maps to a module, which layout imports work, and the `python-deps` vs. `runtime-deps` split.
- [vfs-model-stories.md](.agent-docs/vfs-model-stories.md) — user stories defining the intended scope of the VFS model — opaque ingest, authored `text`, per-leaf copy, link collapsing — and each capability's current status.
- [materialize.md](.agent-docs/materialize.md) — the physical step: payload branch, per-leaf copy with link collapsing, why it always builds, measured costs, why not a derivation per file, and the tool matrix.
- [str-indexing.md](.agent-docs/str-indexing.md) — how `at`, `slice`, and `range` compose, the signed index-label model, and where slicing deliberately diverges from Python.
- [module-layout.md](.agent-docs/module-layout.md) — where a file goes, how it maps to `sundry.*`, and when to split code vs. keep it together.
- [authoring.md](.agent-docs/authoring.md) — how to build a function: compose existing primitives, keep pipe chains visible, derive related conditions from one condition, prefer the simplest model, and use few units.
- [testing.md](.agent-docs/testing.md) — test format (`tests = { <name> = [ actual expected ]; }`) and running tests with `nu ./eval-tests.nu`.
- [test-naming.md](.agent-docs/test-naming.md) — naming conventions for test fixtures.
- [gotchas.md](.agent-docs/gotchas.md) — counter-intuitive lazy evaluation, empty-branch, text-forcing leaf recognition, authored-text precedence, reform-collision, collision-only directory validation, implicit path-to-store coercion, string-context propagation, per-file copy import breakage, non-detectable content class, ingest rejection of a symlink aborting the whole tree, nushell `cp` exit codes on a dangling link, uncatchable symlink reads, unreferenced store links in eval-time copies, hand-built path segments escaping the output, derivation-origin leaves, already-resolved tag rejection, and signed string indices that must not be normalized.

When you add, rename, or remove a doc under `.agent-docs/`, update this index in the same change so it does not drift from what's on disk.
