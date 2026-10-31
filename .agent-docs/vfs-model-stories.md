# VFS model user stories

The VFS model was built around text documents: a leaf carries `text` in memory, and `origin` records where it came from. That covers eval-time selection and rewriting, but it is not a filesystem model.

The contract these stories target separates the two roles. Ingest is **opaque**: `from-src` records `origin` and opens nothing. `text` exists only when a leaf is **authored**, and is the sole producer's output: `edit`. Presence of `text` therefore means "these bytes came from Nix and outrank `origin`", which is what lets materialization branch without guessing. Reading is `sundry.vfs.file.read`, a function that returns a thunk and never stores it. Entry kind is not represented on the node; ingest rejects anything that is not a regular file or a directory.

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
- Assembly lists the directory but **opens no file**: an imported leaf is opaque and holds only `origin`.
- No content classification happens, so text, binaries, and every byte sequence short of NUL import through one code path. Entry kind is classified, but by `readFileType`, not by content.

**Status: works**, with two stated limits — [file.from-src](../src/vfs/file/from-src.nix) records `origin` after confirming the location is a regular file, and [tree.from-src](../src/vfs/tree/from-src.nix) enumerates files. Physical empty directories are not modelled (US-13), and every non-regular entry is rejected at ingest (US-12, US-20).

### US-03 — Query structure without reading content

**As** a library user, **I want** assembly and structure-only traversals to avoid reading files, **so that** large trees stay cheap to filter and inspect.

- Building a tree from disk does not read file contents.
- `path-strs`, merges, and path- or tag-based filters do not read physical contents.
- Decoding happens only through an explicit `sundry.vfs.file.read` call, and the returned string is never stored in the tree.

**Status: works** for structure traversals — the read is lazy and never forced by `path-strs` or merge. Under the target contract it becomes unconditional instead of depending on laziness of a thunk.

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

**Status: works** — [reform](../src/vfs/tree/reform.nix).

### US-06 — Merge trees

**As** a library user, **I want** to combine trees assembled from different sources.

- Disjoint trees merge structurally, recursing through shared directories.
- A leaf/leaf or leaf/dir collision throws with the colliding path.
- A malformed branch unique to one input passes through: validation is collision-only.

**Status: works** — [merge](../src/vfs/tree/merge.nix) and the `dirs` resolver.

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

**Status: works** — [load-nix](../src/vfs/tree/load-nix.nix).

## Materializing

### US-09 — Materialize a tree

**As** a library user, **I want** a VFS tree to become a store tree that a builder can consume.

- The result is `{ drv, tree }`.
- Every leaf becomes a file at the same relative path, with parent directories created.
- An authored leaf (`text`) is written; an opaque leaf (`origin` only) is copied.
- `tree` leaves drop `text` and every payload field, keep `tag-list`, and point into `drv`, so the result is opaque and can be copied again while tag selection still works.

**Status: works** — [materialize](../src/vfs/tree/materialize.nix) writes authored leaves from `builtins.toFile` results, copies opaque ones per leaf, and creates the parent directories of files.

### US-10 — Materialize content that stays out of Nix memory

**As** a library user, **I want** an opaque leaf's bytes to be copied rather than loaded into the evaluator, **so that** binaries, large files, and already-built store files work.

- A leaf with `origin` and no `text` is copied byte-for-byte.
- Eval never calls `readFile` on that `origin`.
- `origin` must be a path, a store path, or a derivation. A non-store string is either normalized through `to-store-str` or rejected with the leaf's path.
- The copy is **per leaf**, which works because no leaf depends on a sibling: an out-of-store location is frozen by `to-store-str`/`builtins.path`, a store location is copied straight from the store object.
- `sundry.vfs.file.read` on such a leaf still decodes; `materialize` never does.

**Status: works** — opaque leaves are copied without being read; an out-of-store `origin` is normalized through [`to-store-str`](../src/path/to-store-str.nix) first. The copy is per leaf, and that is sufficient because every leaf is an independent regular file.

### US-11 — Preserve the executable bit

**As** a library user, **I want** a script in the tree to arrive executable.

- Copying an opaque leaf preserves the source mode the store can express: `0555` for executable files, `0444` otherwise.
- Writing an authored leaf yields a non-executable file, because a Nix string carries no mode; a script that must stay executable travels as opaque.
- No other mode is promised, because the store canonicalizes files and directories.

**Status: works** — opaque leaves are copied from their source with the builtin `cp`, so an executable source arrives executable. Authored leaves are copied from a `toFile` store object and stay `0444`; that is the documented limitation of the authored branch.

### US-12 — Symlinks are out of scope

**As** a library user, **I want** a link in a source tree to be rejected rather than silently resolved, **so that** a tree's output depends only on the tree.

- A VFS tree holds documents: bytes at a path. A link is a pointer to bytes elsewhere, and `builtins` exposes no `readlink`, so eval cannot learn where it points.
- Dereferencing would spend the guarantee that the tree is a self-contained input. A relative link can point above the root; an absolute one names mutable host state. The same tree would then yield different bytes on different machines.
- Preserving is not an option either: the output is a store object meant to carry bytes, and a pointer would keep it dependent on a context that may disappear.
- A link is therefore not represented at any stage. Ingest rejects it (US-20), so `materialize` never sees one from a source tree.

**Status: works** — the ingest primitive, [file.from-src](../src/vfs/file/from-src.nix), accepts only an entry whose `readFileType` is `regular`, so [tree.from-src](../src/vfs/tree/from-src.nix) inherits the rejection for every leaf it enumerates. A hand-built leaf may still point at a link; `materialize` dereferences it as the caller's own input (see [materialize.md](materialize.md#links-that-remain-possible)).

### US-13 — Empty directories are not part of the model

**As** a maintainer, **I want** the treatment of empty directories to be explicit, **so that** nobody chases a non-goal.

- `{}` is a valid directory node, and structure-only operations preserve it.
- A physical empty directory does not become a node: import discovers files, and a directory with no files has nothing to import.
- Materialization creates only the parents of files, so an empty branch with no files is not recreated.
- This is deliberate. A VFS tree is a tree of documents; an empty directory carries no document and no bytes.

**Status: out of scope** — import and materialization are file-oriented by contract.

### US-14 — Treat names as data

**As** a library user, **I want** arbitrary file names to round-trip.

- Names containing spaces, `$`, backticks, quotes, newlines, backslashes, and leading `-` arrive unchanged.
- No name undergoes shell expansion.

**Status: works** — paths travel to the builder as JSON and are joined with `path join`, so `$`, backticks, quotes, newlines, backslashes, spaces, and leading `-` arrive unchanged and are never expanded. A test covers a leading `-` and a literal `$` in a file name.

### US-15 — Handle arbitrary bytes

**As** a library user, **I want** binary content to work, or to fail early with a clear message.

- Opaque content is copied byte-for-byte, so NUL and every other byte sequence round-trip.
- Only an explicit `file.read` on such a leaf can fail, at that call and not at assembly.

**Status: partial** — non-NUL bytes survive a write; NUL aborts only because the current path reads every file. Opaque copying removes the limitation entirely.

### US-16 — Materialize a subset

**As** a library user, **I want** to materialize only the leaves I selected.

- Selection uses path or tag predicates.
- Authored leaves in the selection are written; unselected authored leaves are not.
- Opaque leaves in the selection are copied, and only selected leaves are copied: dereferencing means a leaf does not drag its siblings along.
- A selection over an ingested tree contains only regular files, so no selected leaf depends on an unselected sibling.

**Status: partial** — selecting by path or tag and then materializing works for authored leaves; one opaque leaf in the selection aborts.

### US-17 — Depend only on the tree

**As** a library user, **I want** output that does not depend on the surrounding environment.

- The result is independent of working directory, `umask`, locale, uid, mtime, and builder environment variables.

**Status: works** for the shell surface — names and content are escaped, so builder environment variables do not leak into paths or bytes. Mode and timestamps still normalize by store rules, which is the documented contract.

### US-18 — Keep content out of the derivation

**As** a library user, **I want** the tree's store object to reference content rather than embed it, **so that** derivation size does not grow with total content size.

- Authored content travels through `builtins.toFile`, so the derivation expression carries store paths.
- Opaque content is copied from its origin, so its bytes never enter the expression.
- Per-file rebuild is **not** a goal: the tree is one store object, so a consumer of the tree rebuilds when any byte changes. Splitting it into a derivation per file costs ≈20 ms per file against ≈30 µs for copying, and buys only avoided re-copies.

**Status: works** — authored content is content-addressed by `builtins.toFile`, so the derivation carries store paths; opaque content is copied from its origin. One derivation per tree, as [materialize.md](materialize.md#why-not-one-derivation-per-file) argues.

## Contracts and safety

### US-19 — One leaf type, two payload states

**As** a library author, **I want** traversals, merges, tag resolution, and path rewrites to accept opaque and authored leaves alike.

- Both states are leaves: `is-leaf` accepts `{ origin }` and `{ text }`.
- The state is presence-based: `text` present means authored and outranks `origin`; absent means opaque. `sundry.vfs.node.is-opaque` exposes that test.
- No heuristic distinguishes them, so `materialize` branches on `node ? text` and nothing else.
- Structure-only operations never read, and `sundry.vfs.file.read` never stores what it reads.

**Status: works** — [is-opaque](../src/vfs/node/is-opaque.nix) tests presence, ingest produces opaque leaves, and `materialize` branches on it.

### US-20 — Fail on unrepresentable entries with their own path

**As** a library user, **I want** an entry that cannot be represented to fail with the *entry's* path, **so that** one odd file does not abort or hang an unrelated import.

- `builtins.readFileType` reports four kinds: `regular`, `directory`, `symlink`, and `unknown`. `unknown` is the catch-all for fifo, socket, and device, which the evaluator cannot tell apart and does not need to.
- The check lives in the primitive, [file.from-src](../src/vfs/file/from-src.nix), which accepts only `regular` and throws for the rest, naming the VFS path and the reported kind. [tree.from-src](../src/vfs/tree/from-src.nix) is a combinator over it, so it inherits the rejection without repeating it.
- Classification is free: `readFileType` is `lstat`, so no file is opened and no store copy is made.
- Reading an opaque leaf through `sundry.vfs.file.read` may still fail uncatchably, but only for the caller that asked; ingest can no longer produce the entries that hang it.

**Status: works** — [file.from-src](../src/vfs/file/from-src.nix) throws `vfs.file.from-src: [ "B" ] is a 'symlink' entry; only a regular file can be ingested`.

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

**Status: works** — [load-nix](../src/vfs/tree/load-nix.nix).

### US-23 — Compose and build a project

**As** a library user, **I want** several sources plus generated files to become one buildable tree.

- Imported trees and generated files merge into one VFS.
- Tags select the leaves to interpret.
- Materialization yields the build input; the Python wrapper consumes it as an application.
- A tree mixing authored leaves (the generated `pyproject.toml`) with opaque leaves (the imported source) materializes by writing one and copying the other.
- The source root is the wheel root.

**Status: works** — subject to the layout contract in [python-script.md](python-script.md).

### US-24 — Never classify content

**As** a library author, **I want** ingest to avoid deciding whether a file is text, **because** eval cannot detect it and does not need to.

- Ingest records `origin` and nothing else; it has no predicate parameter and never probes bytes.
- A consumer that wants text calls `sundry.vfs.file.read` and accepts the decode risk at that point; `edit` promotes the result to authored content.
- No eval code branches on a failed `readFile`.

Why it cannot be detection:

- `readFileType` returns `regular` for an ELF binary and for a Markdown file alike; entry kind says nothing about content.
- The only in-eval signal is the absence of NUL, and the failure is not catchable: `tryEval (stringLength (readFile elfPath))` re-throws `the contents of the file '…' cannot be represented as a Nix string`. `builtins` exposes no size, `stat`, or prefix read, so magic bytes are unreachable — `readFile` decodes the whole file before returning.
- `hashFile` does read raw bytes of a binary, but yields only a digest.
- A build-time probe works (a `runCommand` that compares `wc -c` with `tr -d '\0'`, read back via `readFile`) and returns `text` for an ELF-free script and `binary` for ELF, but it is IFD: a build per file during evaluation, forbidden under `--pure-eval`, and invalidated by any content change.
- Non-UTF-8 bytes are not a signal: Nix strings are byte strings and `\xff\xfe\x01` passes. The boundary is exactly the byte `0x00`.

**Status: missing** — import still calls `readFile` on every entry. The target contract removes the question instead of answering it: opaque ingest makes classification unnecessary, and `sundry.vfs.file.read` makes decoding a local, explicit choice.

### US-25 — Read without authoring

**As** a library user, **I want** to read a leaf's contents without turning it into an edit.

```nix
sundry.vfs.file.read :: file -> text
```

- Returns `file.text` when authored, otherwise a lazy `builtins.readFile file.origin`.
- The returned thunk is never stored in the tree, so reading leaves the payload state unchanged.
- A consumer that only inspects contents (filtering, templating, logging) can read a whole tree without promoting any leaf to authored.
- The costs of decoding — chiefly a NUL abort — belong to the caller that asked.
- It takes a leaf, not a path, so it cannot name a VFS path in an error; callers reach it through `is-leaf` or `halt`.

**Status: works** — [read.nix](../src/vfs/file/read.nix). Until ingest is opaque (US-02), the opaque branch is reachable only for hand-built leaves and post-materialization `dir` values, because `from-src` still stores `text`.

### US-26 — `edit` is the only content author

**As** a library author, **I want** one leaf-level operation that changes contents, **so that** an authored payload can never coexist with a location that silently wins.

```nix
sundry.vfs.file.edit :: (text -> text) -> file -> file
```

- Sets `text = fn (read file)` and keeps `origin` for provenance.
- A rewrite is local: `edit` takes a leaf, not a tree; a tree-level transformation applies it per leaf.
- Any operation that changes contents routes through `edit`; no code writes `text` in place while leaving an `origin` that describes the old bytes.
- Removing `text` reverts the leaf to opaque, so dropping an edit is an explicit choice.
- Arguments are function first, file last, matching the data-last convention of the other `vfs.file` helpers.

**Status: works** — [edit.nix](../src/vfs/file/edit.nix) is the only writer of `text` in library code, and no traversal writes it: `walk`, `reform`, `filter`, `collapse`, and `select` only pass leaves to a caller-supplied callback. Text rewrites inside the `walk` and `reform` test blocks are test callbacks, not library behavior.

## Model axes

| axis | target | where it stands |
|---|---|---|
| payload state | opaque at ingest; authored only through `edit` | works (US-02, US-19, US-25, US-26) |
| leaf content | `text` present means authored and outranks `origin` | works (US-10, US-19) |
| entry kind | unrepresented on the node; regular files and directories only, everything else rejected at ingest | works (US-12, US-20) |
| mode | preserved for opaque leaves; `0444` for authored | works (US-11) |
| directories | structural `{}`; empty physical directories are not modelled | out of scope (US-13) |
| names | byte-faithful and shell-safe | works (US-14, US-17) |
| provenance | a location in both states, never the payload of an authored leaf | works (US-04, US-19) |
| laziness | nothing read at ingest; `read` returns unretained thunks | works (US-03, US-25) |
| store object | one derivation carrying store paths, not bytes | works (US-18) |

## What the stories force

- `text` is a declaration, not a cache. Presence means "these bytes came from Nix"; absence means "copy the location". One bit of state, no heuristic.
- Reading and authoring are different operations. `sundry.vfs.file.read` returns a thunk and never stores it; `sundry.vfs.file.edit` is the only writer of `text`. A transformation that rewrites contents without `edit` is a silent bug.
- Ingest is opaque, so eval never opens a file. The decode risk — a NUL abort — moves to the caller that explicitly asks, while an entry the store cannot carry is rejected at ingest with its VFS path.
- Links are not content. Eval cannot see a target (`readlink` is absent), so a link cannot be collapsed faithfully: resolving one imports host state and preserving one imports a pointer. Ingest rejects it instead.
- Copying is per leaf because every ingested leaf is an independent regular file; nothing in the tree depends on a sibling.
- Most of the physical step is a plain copy: `cp` preserves modes, and `builtins.toFile` keeps authored content out of the derivation expression. The library's own work is path mapping and the payload branch, not reimplementing a copy.
