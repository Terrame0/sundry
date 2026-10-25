# VFS model user stories

The VFS model was built around text documents: a leaf carries `text` in memory, and `origin` records where it came from. That covers eval-time selection and rewriting, but it is not a filesystem model. Entry kind, permissions, empty directories, opaque content, and byte-faithful names have no representation, and `origin` currently serves as both provenance and a would-be payload.

These stories state the target model from a consumer's point of view. They define scope, not implementation order.

| status | meaning |
|---|---|
| **works** | implemented and covered by tests |
| **partial** | works for the in-memory model; the gap is at a physical stage or for non-text leaves |
| **missing** | no representation exists today |
| **out of scope** | deliberately excluded because the store cannot carry it |

## Authoring and importing

### US-01 — Generate a file from text

**As** a library user, **I want** to add generated content at a chosen VFS path, **so that** it composes with imported files.

- `file.from-text ["A" "B.txt"] text` produces `{ A."B.txt" = { text = "..."; }; }`.
- The path is a non-empty segment list; `[]` throws.
- Building the tree performs no filesystem access.

**Status: works** — [from-text](../src/vfs/file/from-text.nix).

### US-02 — Import a physical tree

**As** a library user, **I want** every regular file below a directory to appear at its path relative to that directory.

- Relative paths are computed against the given root, not the store or the working directory.
- `origin` preserves the input type: a path argument produces a path, a string produces a string.
- Contents are read lazily; assembly lists the directory but reads no file contents.

**Status: partial** — works for regular files via [from-src](../src/vfs/dir/from-src.nix). Every non-directory entry is read as a regular file, including symlinks and special files.

### US-03 — Query structure without reading content

**As** a library user, **I want** assembly and structure-only traversals to avoid reading files, **so that** large trees stay cheap to filter and inspect.

- Building a tree from disk does not read file contents.
- `path-strs`, merges, and path- or tag-based filters do not read physical contents.
- Only content consumers read them: materialization and callbacks that read `file.text`.

**Status: works** — the lazy read is locked by `does-throw-whnf` tests.

### US-04 — Keep provenance

**As** a library user, **I want** to know a leaf's physical location independently of its logical path.

- `origin` accepts a path, a string, or a derivation.
- Path rewrites leave `origin` unchanged.
- `get-relative-to` resolves a path under a known root to its node.
- Materialization replaces `origin` with the new store path.

**Status: works** — [data-model.md](data-model.md) defines the field.

## Rearranging and selecting

### US-05 — Rewrite logical paths

**As** a library user, **I want** to move leaves within the tree without touching their physical origin.

- The callback returns `{ path, value }`; `omit = true` drops the leaf.
- Each leaf maps to zero or one leaf: relocation is allowed, splitting is not.
- Collisions in the rebuilt tree throw.

**Status: works** — [reform](../src/vfs/dir/reform.nix).

### US-06 — Merge trees

**As** a library user, **I want** to combine trees assembled from different sources.

- Disjoint trees merge structurally, recursing through shared directories.
- A leaf/leaf or leaf/dir collision throws with the colliding path.
- A malformed branch unique to one input passes through: validation is collision-only.

**Status: works** — [merge](../src/vfs/dir/merge.nix) and the `dirs` resolver.

### US-07 — Annotate and select by tags

**As** a library user, **I want** tags in path segments to drive selection without polluting the logical path.

- `{key:value}` is stripped from the logical segment and recorded in the per-segment `tag-list`.
- `strip-tags` removes annotations and `tag-list`; it is idempotent.
- Tag queries drive select, filter, walk, and reform variants.
- Resolving an already-resolved tree throws.

**Status: works** — [tag-resolution.md](tag-resolution.md).

### US-08 — Evaluate Nix leaves lazily

**As** a library user, **I want** selected `.nix` leaves to become expressions without importing the whole tree.

- Matching leaves gain `expr`.
- `expr` is lazy; a missing or invalid origin surfaces only when the import is forced.
- Relative imports inside a loaded file resolve against that file's directory.

**Status: works** — [load-nix](../src/vfs/dir/load-nix.nix).

## Materializing

### US-09 — Materialize a text tree

**As** a library user, **I want** an in-memory tree to become a store tree that a builder can consume.

- The result is `{ drv, dir }`.
- Every materialized leaf becomes a file at the same relative path, with parent directories created.
- `dir` leaves drop `text` and point into `drv`.

**Status: partial** — [materialize](../src/vfs/dir/materialize.nix). Gaps: `drv` forces every leaf's `text`; a leaf without `text` throws; the whole tree is one derivation; names are interpolated into shell; NUL content cannot be represented.

### US-10 — Materialize content that stays out of Nix memory

**As** a library user, **I want** a leaf's bytes to be copied or referenced rather than loaded into the evaluator, **so that** binaries, large files, and already-built store files work.

- A leaf with `origin` and no `text` materializes by copying or referencing `origin`.
- Eval never calls `readFile` on that `origin`.
- `origin` must be a path, a store path, or a derivation; a non-store string fails with the leaf's path in the message.
- Asking for `text` on such a leaf throws instead of returning an empty string.

**Status: missing** — `is-leaf` accepts an origin-only leaf, but materialization rejects it. `from-src` always attaches `text`, so only external stages and post-materialization `dir` values reach this shape.

### US-11 — Preserve the executable bit

**As** a library user, **I want** a script in the tree to arrive executable.

- A source file with any exec bit materializes as `0555`; every other file is `0444`.
- No other mode is promised, because the store canonicalizes files and directories.

**Status: missing** — materialization writes through `printf >`, so every file is `0444`. The node model has no field for it, and import discards the mode.

### US-12 — Dereference symlinks at import

**As** a library user, **I want** a symlink to import as the regular file it points at, **so that** the materialized tree contains concrete bytes with no live pointers.

- A symlink is dereferenced by `readFile`: the node is an ordinary leaf with `text` and `origin` pointing at the link path.
- Duplicated bytes from in-tree chains (`libfoo.so -> libfoo.so.1 -> libfoo.so.1.2.3`) are accepted; the store is content-addressed, so a duplicate costs size, not correctness.
- Links into `/nix/store` are frozen into the importing derivation rather than kept as pointers, so the result does not depend on another store object surviving garbage collection.
- Preserving a link as a link is **out of scope**. A store copy would fix the pointer, not the referent: an in-tree relative link happens to keep working because the whole tree moves, but an absolute link to the source, or a relative link that climbs out of the root, still resolves outside the output. A materialized tree must not contain pointers to mutable state.

**Status: works by accident, wrong failure modes** — every non-directory entry is read through, so the content is right. A dangling link and a link to a directory abort evaluation with the *target* path in the message (see [gotchas.md](gotchas.md#readfile-follows-symlinks-and-its-failures-are-uncatchable)); a tree that must round-trip link identity instead of content cannot use `from-src`.

### US-13 — Preserve empty directories

**As** a library user, **I want** an empty directory in the tree to survive to the store.

- `{}` is already a directory node; import and materialization preserve it.
- If it stays implicit, the limitation is stated instead of silently dropping the branch.

**Status: partial** — `{}` is a directory node and survives structure-only operations, but import lists files only and materialization creates only the parents of files.

### US-14 — Treat names as data

**As** a library user, **I want** arbitrary file names to round-trip.

- Names containing spaces, `$`, backticks, quotes, newlines, backslashes, and leading `-` arrive unchanged.
- No name undergoes shell expansion.

**Status: missing** — materialization interpolates the path into a double-quoted shell word, so `run$name.sh` becomes `run<drv-name>.sh`; only the text is escaped.

### US-15 — Handle arbitrary bytes

**As** a library user, **I want** binary content to work, or to fail early with a clear message.

- A file containing NUL either travels the opaque path or is rejected at import with its path named.
- Every other byte sequence round-trips.

**Status: partial** — non-NUL bytes survive; NUL aborts evaluation with `cannot be represented as a Nix string`.

### US-16 — Materialize a subset

**As** a library user, **I want** to materialize only the leaves I selected.

- Selection uses path or tag predicates.
- Only selected leaves are forced or copied; unselected leaves keep their `origin` and are not read.
- Opaque leaves in the selection pass through.

**Status: partial** — selecting by path or tag and then materializing works for text leaves; one opaque leaf in the selection aborts.

### US-17 — Depend only on the tree

**As** a library user, **I want** output that does not depend on the surrounding environment.

- The result is independent of working directory, `umask`, locale, uid, mtime, and builder environment variables.

**Status: partial** — text trees are stable, but a name containing `$` expands from the builder environment, so it is not.

### US-18 — Rebuild per file

**As** a library user, **I want** a change to one file to rebuild only that file.

- Content is content-addressed per file.
- The tree derivation references those objects instead of embedding their bytes.
- Derivation size does not grow with total content size.

**Status: missing** — one `runCommand` embeds every `text`.

## Contracts and safety

### US-19 — One leaf type, two representations

**As** a library author, **I want** traversals, merges, tag resolution, and path rewrites to accept decoded and opaque leaves alike.

- `is-leaf` recognizes both representations.
- The representation is an explicit field, not the absence of `text`.
- Content access on an opaque leaf throws; structure-only access never forces content.

**Status: missing** — `text` presence is the implicit discriminator, and `origin` is both provenance and would-be payload.

### US-20 — Reject non-regular, non-link entries by path

**As** a library user, **I want** entries that cannot be dereferenced to fail fast with the *entry's* path, **so that** one odd file does not abort or hang an unrelated import.

- Import classifies each entry with `readDir` / `readFileType` before reading it.
- A fifo, socket, or device is rejected with its VFS path; no reader is opened, because opening a fifo blocks the evaluator.
- A dangling link or a link to a directory is rejected with the *link's* path, not the target's.
- A regular file and a link that resolves to a regular file are imported.

**Status: missing** — every non-directory entry is handed to `readFile`. Entry type is discarded by `lib.filesystem.listFilesRecursive`, so a fifo hangs evaluation, and a dangling or dir link aborts with the target path in the message.

### US-21 — Exclude unrepresentable metadata explicitly

**As** a maintainer, **I want** the model's exclusions written down.

- Ownership, ACLs, xattrs, mtime, hardlink identity, and sparse layout are not represented.
- The documented normalization is the contract.

**Status: out of scope** — the store cannot carry them.

### US-22 — Keep relative imports working while loading

**As** a library user, **I want** a loaded `.nix` file to import its siblings.

- `origin` is not normalized to a per-file store copy.
- Whole-tree copies keep siblings together.
- `load-nix` imports the exact `origin` value.

**Status: works** — [load-nix](../src/vfs/dir/load-nix.nix).

### US-23 — Compose and build a project

**As** a library user, **I want** several sources plus generated files to become one buildable tree.

- Imported trees and generated files merge into one VFS.
- Tags select the leaves to interpret.
- Materialization yields the build input; the Python wrapper consumes it as an application.
- The source root is the wheel root.

**Status: works** — subject to the layout contract in [python-script.md](python-script.md).

## Model axes

| axis | today | stories that require more |
|---|---|---|
| leaf content | in-memory `text` | decoded text or opaque copy (US-10, US-15, US-19) |
| entry kind | any non-directory entry read as a file | regular files and dereferenced links; reject the rest (US-12, US-20) |
| mode | store-canonical | executable flag (US-11) |
| directories | structural `{}` | preserved through import and materialization (US-13) |
| names | attrset keys | byte-faithful and shell-safe (US-14, US-17) |
| provenance | `origin` | split from payload (US-10, US-19) |
| laziness | lazy import, eager materialization | per leaf, copy without read (US-03, US-16, US-18) |
| granularity | one derivation per tree | per-file objects (US-18) |

## What the stories force

- `text` and `origin` cannot keep doubling. One field is decoded content, the other is a location; an opaque leaf makes the difference visible.
- The representation belongs in `is-leaf` and in one content accessor. Traversals branch on it once; every consumer branching on `text` would spread the gap.
- Materialization is where the physical contract is decided. Import must classify entries and reject what it cannot dereference; the exec bit and name fidelity belong to materialization, or the contract is text-only by declaration.
- Link identity is not content. The model stores bytes; a pointer is either dereferenced at import or refused, because nothing a store keeps can make a pointer hermetic.
