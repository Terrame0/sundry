# VFS lifecycle

VFS operations transform trees of the node shapes defined in [data-model.md](data-model.md). They represent the logical VFS path separately from a leaf's physical `origin`.

## Constructors return trees

[`file.from-text`](../src/vfs/file/from-text.nix) and [`file.from-src`](../src/vfs/file/from-src.nix) return a one-file tree created with `lib.setAttrByPath`, not a bare leaf:

```nix
sundry.vfs.file.from-text ["A" "B.txt"] "contents"
# => { A."B.txt" = { text = "contents"; }; }
```

Both require a non-empty VFS path. `from-text` authors contents: it adds `text` and no `origin`. `from-src` ingests a location: it confirms with `readFileType` that the location is a regular file, then adds `origin` and **opens nothing**, so an imported leaf is opaque and its bytes stay on disk until something asks for them. `from-src` stores its `fs-path` argument unchanged, so a raw Nix path produces a path-typed `origin` and a string produces a string-typed one; [is-leaf](../src/vfs/node/is-leaf.nix) accepts a path, string, or derivation, and the derivation form matters downstream when a stage re-points `origin` at a build output.

Neither constructor type-checks `text`; [`is-leaf`](../src/vfs/node/is-leaf.nix) is the classifier that rejects a scalar non-string `text` (an attrset-shaped one is read as a directory, per [data-model.md](data-model.md)). [`tree.from-src`](../src/vfs/tree/from-src.nix) enumerates the files below a directory, maps each to its relative VFS path through [`file.from-src`](../src/vfs/file/from-src.nix), and combines the one-file trees with `recursive.no-collision`. It owns no classification of its own: the primitive accepts only a regular file, so a link, fifo, socket, or device rejects the whole tree (US-12).

Ingest is opaque by contract: it enumerates names, `lstat`s each entry to reject the ones a leaf cannot represent, and records `origin`, but calls no reader. A decoded leaf exists only when the consumer asks for one, through `sundry.vfs.file.read` — `file.text` when authored, otherwise a lazy `builtins.readFile file.origin`. That thunk is returned and never stored, so reading leaves the node opaque; the cost of decoding — chiefly a NUL abort — is paid by the caller who asked, not by everyone who assembled the tree.

Entry kind is not represented in the node, but it is classified at ingest and constrained there. `readFileType` reports `regular`, `directory`, `symlink`, or `unknown` (the last covers fifo, socket, and device); the leaf primitive accepts only `regular`, and the directory combinator recurses on directories. A link cannot be handled faithfully: eval cannot see its target, dereferencing it imports state from outside the tree, and preserving it keeps the output dependent on a context. It is rejected instead, with its VFS path and reported kind. See [materialize.md](materialize.md#non-regular-entries-are-rejected-at-ingest).

Opaque materialization copies one leaf at a time and needs no enclosing tree, because every ingested leaf is an independent regular file. An out-of-store `origin` is normalized through [`to-store-str`](../src/path/to-store-str.nix), which calls `builtins.path` on the single path. A store-resident `origin` becomes a string that keeps its store object alive, and the builder copies it with the builtin `cp`, which dereferences a file link and rejects a directory link. Per-file store copies break relative `.nix` imports only because `import` reads `origin` directly, not through this step (see [gotchas.md](gotchas.md#per-file-store-copies-break-relative-imports)). [materialize.md](materialize.md) describes the copy.

## Assemble first, interpret later

Construction and semantic interpretation are separate stages. `from-src` is one way to populate a VFS, not the owner of the later lifecycle. A caller can assemble one tree from several physical directories, individual files, and leaves generated in Nix expressions. Generated leaves can hold design-system partials or other artifacts that do not exist in any source directory.

For example, the VFS-aware merge resolver described in [attrs-merge.md](attrs-merge.md) can combine several imported trees with a generated file:

```nix
sundry.attrs.merge.dirs.no-collision [
  (sundry.vfs.tree.from-src source-a)
  (sundry.vfs.tree.from-src source-b)
  (sundry.vfs.file.from-text
    ["components{kind:partial}" "_tokens.scss"]
    generated-tokens)
]
```

Run `resolve-tags` after assembly so every source follows the same logical-path and tag rules. Keep `load-nix` as a separate stage because importability is a property of an individual leaf: physical leaves can have `origin`, while generated text leaves do not have one unless they are materialized first. The caller can select the intended Nix leaves, materialize generated Nix files when necessary, and load only that subset without forcing unrelated generated files through `from-src` or `load-nix`.

## Transformation stages

| operation | input requirement | leaf fields after the operation |
|---|---|---|
| `file.from-text` | non-empty VFS path, string contents | `text` (authored, no `origin`) |
| `file.from-src` | path to a regular file | `origin` only; nothing is read |
| `tree.from-src` | path to a directory | `origin` only per leaf; nothing is read |
| `sundry.vfs.file.read` | leaf with `text` or `origin` | unchanged; returns `text` or a lazy `readFile origin` thunk |
| `sundry.vfs.file.edit fn` | leaf with `text` or `origin` | `text = fn (read file)`; `origin` kept for provenance |
| [`tree.resolve-tags`](../src/vfs/tree/resolve-tags.nix) | valid VFS tree without `tag-list` | existing fields plus `tag-list`; logical paths are cleaned |
| [`tree.strip-tags`](../src/vfs/tree/strip-tags.nix) | valid VFS tree | `tag-list` removed; logical paths are cleaned |
| [`tree.load-nix`](../src/vfs/tree/load-nix.nix) | `origin` when the import is demanded | existing fields plus `expr` |
| `tree.load-nix-with fn` | `origin` when `fn` demands the imported value | existing fields plus `expr = fn path file imported` |
| [`tree.materialize name`](../src/vfs/tree/materialize.nix) | every leaf has `text` or `origin` | returns `{ drv, tree }`; every leaf's `text` and other payload fields are removed, `origin` points into `drv`, and `tag-list` is kept |

`resolve-tags` is explained in [tag-resolution.md](tag-resolution.md). Tag-aware selection and `*-within-tag` transformations require its `tag-list` field; they do not synthesize missing tags. `strip-tags` neutralizes annotations and `tag-list` for handing a tree to a pipeline that owns its own tag logic; unlike `resolve-tags`, it is idempotent and safe on an already-resolved tree.

`load-nix` and `load-nix-with` visit every leaf regardless of its extension. Nix keeps `import file.origin` lazy, so a missing or invalid `origin` surfaces only when the callback or its stored `expr` demands the import. Select the intended files before loading when the tree also contains non-Nix files.

`materialize` returns two related values:

```text
{
  drv = store object containing all materialized files and their parent directories;
  tree = VFS index whose leaf origins point inside drv and whose tag-lists are kept;
}
```

Each leaf is materialized according to its payload state:

| state | action |
|---|---|
| authored (`text` present) | write `text`; `origin` is provenance only and is not read |
| opaque (`origin` only) | copy `origin` byte-for-byte, preserving the executable bit |

The branch is presence-based, so there is no "text or origin?" guess. An authored leaf always wins over its own `origin`, which is what makes `edit` reliable: changing contents never leaves a stale location that silently takes priority.

Materialization always builds: eval turns the tree into a JSON plan of store paths, and a nushell builder replays it with `cp` and `mkdir`. There is no evaluation-time shortcut — a tree that needs no rewrite and no authored leaf needs no materialization at all, and the caller passes the path. [materialize.md](materialize.md) gives the tool matrix, measured costs, and why a derivation per file is not worth it.

The builtin `cp` dereferences a hand-built leaf's file link, which is the caller's own input, and rejects a directory link with an error. A working-copy dangling link fails in `to-store-str`; a store-resident dangling or cyclic one is dropped with exit code `0` (see [gotchas.md](gotchas.md#nushells-builtin-cp-exits-0-when-a-link-dangles)). Ingest rejects links, so a source tree never reaches this branch.

Returning this attrset checks nothing about contents. Demanding the store object walks the tree's paths and, for authored leaves, includes their `text`; opaque leaves contribute their location, not their bytes, so a large binary does not enter the derivation expression. Translation is still per tree: one change anywhere rebuilds the whole output.

Continue VFS transformations through `result.tree`; use `result.drv` when a build input needs the physical file tree. Materialization deliberately drops `text` so memory contents cannot drift from the materialized file; the resulting tree is opaque, and a second materialization is a copy rather than a rewrite. `tag-list` is preserved because it describes the logical path, which materialization does not change — without it, tag selection on a materialized tree would be impossible and the tags are not recoverable from the stripped segments.

The implementation copies each opaque leaf individually after normalizing its `origin` through `to-store-str`, which is the target strategy; [materialize.md](materialize.md) explains why tree-scoped and per-file strategies lose. [vfs-model-stories.md](vfs-model-stories.md) tracks what remains open.

## Traversal boundary

`sundry.vfs.tree.{walk, collapse, reform, filter, path-strs}` use `sundry.vfs.node.halt` as the generic traversal `halt`. They recurse through directories, expose complete leaves to callbacks, and report demanded malformed children with their path. The root attrset remains the directory container and is not passed to `halt`.

See [attrs-traversal.md](attrs-traversal.md) for callback variants and the different strictness of `walk`, `collapse`, `reform`, and `filter`. Physical empty-directory behavior and structure-only validation are covered in [gotchas.md](gotchas.md).
