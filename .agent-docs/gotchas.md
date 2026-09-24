# Gotchas

These are counter-intuitive mechanics that can silently invalidate an otherwise plausible change.

## Traversal strictness depends on the family

Rule: distinguish structural traversal from forcing the values produced by callbacks.

Why: `walk` is branch-lazy, while evaluating `collapse`, `reform`, or `filter` forces their complete traversal structure. Nested replacement values and leaf payload fields can remain lazy in every family. [attrs-traversal.md](attrs-traversal.md#terminal-nodes) gives the exact boundaries.

Avoid it: use [`sundry.does-throw`](testing.md#does-throw-does-not-catch-everything) when the question is whether the **entire result, including payload**, evaluates. For VFS structure-only validation without forcing lazy `expr`, deeply force a payload-free projection such as `sundry.vfs.dir.path-strs tree` or `sundry.vfs.dir.collapse (_: _: null) tree`.

## Leaf recognition forces `text` unless `origin` is tested first

Rule: keep the `origin` checks before the `text` check in [`is-leaf`](../src/vfs/node-cond.nix).

Why: `builtins.isString text` forces `text` to weak head normal form. When `text` is a lazily-read `builtins.readFile` thunk, testing it is what reads the file. `is-leaf-node` is the `halt` of every VFS traversal, including structure-only ones such as [`path-strs`](../src/vfs/dir/path-strs.nix) and the [`dirs`](../src/attrs/merge-resolvers/dirs.nix) merge resolver; `||` short-circuits, so testing `origin` first recognizes a physical leaf from its path/string/derivation literal and never evaluates `text`. This keeps those traversals from being a forcing point.

Avoid it: do not reorder the disjunction to test `text` first, and do not add a construction-time type check on `text` to a builder such as [`from-text`](../src/vfs/file/from-text.nix). Any `assert lib.isString text` forces WHNF of the `readFile` thunk that [`from-src`](../src/vfs/file/from-src.nix) puts there, reading every file while the tree is assembled. The leaf type gate is [`is-leaf`](../src/vfs/node-cond.nix); leave validation to the classifier. A generated text-only leaf has no `origin`, so it still forces `text` — an in-memory literal, not file I/O.

The trade-off: without the assert, `from-text ["A"] {}` builds `{A = {text = {};};}`, which the node model classifies as a **directory**, not a malformed leaf (see [data-model.md](data-model.md)). The classifier rejects scalar non-string `text`, but an attrset-shaped one becomes a directory.

## Rebuilding traversals lose traversable empty attrsets

Rule: do not use `collapse`, `reform`, or `filter` when an unhalted empty attrset must survive as a structural node.

Why: recursive `collapse` emits no terminal for `{}`. `reform` and `filter` rebuild their result from those emitted terminals, so they also lose that branch. `walk` maps the existing shape and preserves it. In VFS, `{}` is a valid empty directory, making this difference observable.

Avoid it: use `walk`, make the empty attrset terminal through `halt`, or restore required empty branches explicitly.

The physical VFS roundtrip is file-oriented too: `dir.from-src` discovers files, not empty directories, and `materialize.drv` creates only parents needed by files. `materialize.dir` preserves an existing empty branch through `walk`, but that branch has no directory in the derivation.

## `reform` collision handling is structural, not VFS-aware

Rule: do not assume overlapping target paths from `reform` produce a clean VFS collision error.

Why: reform fragments are combined with `recursive.no-collision`. Two attrset fragments recurse and can combine before terminal fields collide. A valid leaf discriminator then takes precedence over the merged directory fields, so a leaf can silently hide a subtree rather than fail validation.

Avoid it: detect incompatible terminal overlaps before rebuilding. For VFS, do not emit two leaves at one target or make a leaf target the ancestor of another emitted path. Shared directory prefixes are safe. A later VFS traversal catches malformed rebuilt nodes, but cannot detect a hidden subtree once `text` or `origin` makes the combined attrset a valid leaf.

## `dirs` validates collisions only

Rule: use a separate traversal when complete input-tree validation is required.

Why: merge resolvers run only where two inputs contain the same key. A unique malformed branch passes through `sundry.attrs.merge.dirs.*` unchanged.

Avoid it: deeply force `sundry.vfs.dir.path-strs tree` or `sundry.vfs.dir.collapse (_: _: null) tree` when validation outside merge-relevant collisions matters. These projections validate node structure without forcing leaf payload such as `expr`.

## Path values copy to the store under most string operations

Rule: convert a path to a string only with `builtins.toString`; never hand a path to another string builtin.

Why: Nix's path-to-string coercion defaults to `copyToStore = true`, so several string builtins copy the file into `/nix/store` under its basename before returning. A basename that is not a legal store name then aborts evaluation — which is what a `lib.hasSuffix ".nix"` filter over `listFilesRecursive` of a path literal hits on a name such as `что?`. [core/mk-lib.nix](../core/mk-lib.nix) sidesteps it by testing `baseNameOf path`.

| Operation | Effect on a path |
| --- | --- |
| `builtins.toString` | string, no copy |
| `builtins.baseNameOf` / `dirOf` | string, no copy |
| `lib.splitString` | string list, no copy |
| `builtins.readFile` | file contents, no copy |
| `builtins.trace` / `lib.traceValSeq` | no copy |
| `lib.isPath` / `isString`, `builtins.typeOf` | no copy |
| `lib.escapeShellArg`, `lib.generators.toPretty` | string, no copy |
| interpolation `"${path}"` | **copies to store** |
| `builtins.stringLength` (`sundry.str.len`), `lib.substring`, `lib.stringToCharacters` | **copies to store** |
| `lib.hasPrefix` / `hasSuffix` / `hasInfix` / `removePrefix` / `removeSuffix` | **copies to store** |
| `lib.concatStrings` (`sundry.str.join`) / `concatStringsSep` (`sundry.str.join-with`) | **copies to store** |
| `builtins.toJSON` | **copies to store**, even when nested in an attrset |
| `lib.replaceStrings` / `lib.toUpper` | throws `expected a string but found a path` |

Path/string equality does not coerce either way: `path == "/abs/path"` is simply `false`.

Avoid it: keep paths out of string helpers. Filter or compare on `baseNameOf path`, or convert once with `toString` and work on the resulting string. [from-str.nix](../src/vfs/path/from-str.nix) already does the latter with `builtins.unsafeDiscardStringContext (toString path-str)`.

## Store path context survives string operations

Rule: `unsafeDiscardStringContext` a string before using it as a dynamic attribute name or any other context-free datum.

Why: a string that carries store context — e.g. `"${self.outPath}/..."`, since interpolating a path yields a context-carrying string — keeps that context through `toString`, `removeSuffix`, `splitString`, and `removePrefix` (which preserves the context of the sliced string, not of the prefix). Building module paths with `lib.filesystem.listFilesRecursive "${self.outPath}/src"` therefore leaves each path segment carrying the source store path, and Nix rejects it as an attribute name: `the string 'attrs' is not allowed to refer to a store path`. Iterating with a path value (`listFilesRecursive ../src`) avoids this, because `builtins.toString` on a path is context-free. `flake-root` is itself a path (`./.`), so `flake-root + "/src"` is a context-free path; only interpolation (`"${flake-root}/src"`) would copy it to the store and reintroduce the context.

Avoid it: iterate path values and derive names with `toString`; when the input is already a context-carrying string, discard explicitly with `builtins.unsafeDiscardStringContext`. [from-str.nix](../src/vfs/path/from-str.nix) normalizes both cases this way.

## Per-file store copies break relative imports

Rule: never materialize a single `.nix` file with `builtins.path` / interpolation and then `import` it; copy the whole tree instead.

Why: `import` resolves a relative import such as `import ./b.nix` against the importing file's own directory. A per-file `builtins.path { path = ./a.nix; name = "a.nix"; }` lands the copy in the store root, so `./b.nix` is looked up beside the store object: `error: 'b.nix' is too short to be a valid store path`. The tree-level copy from [materialize](../src/vfs/dir/materialize.nix) keeps siblings together and is unaffected.

Avoid it: keep tree-structured sources as path values and let [`dir.materialize`](../src/vfs/dir/materialize.nix) copy the whole tree, or copy a whole directory (`builtins.path { path = ./dir; }`). [`to-store`](../src/path/to-store.nix) leaves a path already inside the store in place — as a context-carrying string pointing at its top-level store object, without copying — so it never breaks relative imports for store-resident files; it copies only paths outside the store.

This is why [`file.from-src`](../src/vfs/file/from-src.nix) stores its `fs-path` unchanged instead of normalizing `origin` to a store string: `origin` is the exact value [`load-nix-with`](../src/vfs/dir/load-nix.nix) feeds to `import`, so a per-file copy there would turn every relative import in a loaded `.nix` into the error above. Normalizing `origin` at construction time plants a mine under the loader; the raw path keeps the tree intact until a stage that legitimately copies it whole.

## `origin` accepts a derivation, and external stages rely on it

Rule: do not narrow the accepted `origin` types to what `sundry`'s own constructors produce; `is-leaf` must keep accepting a derivation.

Why: the node contract is public, and downstream pipelines build derivation origins themselves. [`file.from-src`](../src/vfs/file/from-src.nix) emits a path or string origin, but [`materialize`](../src/vfs/dir/materialize.nix) drops `text`, and a later [`reform`](../src/vfs/dir/reform.nix) can set `origin` to a build derivation — producing a derivation-only leaf. Dropping `lib.isDerivation origin` from [is-leaf](../src/vfs/node-cond.nix) makes such a node neither leaf nor directory, so `is-leaf-node` throws (`... is neither a leaf nor a directory`) on a tree that previously worked.

Avoid it: treat a node with a derivation `origin` as a leaf. When auditing which types a field may hold, check external consumers, not only the in-repo constructors; a library's field contract outlives the call sites visible here.

## `resolve-tags` is not idempotent

Rule: resolve annotations once, before tag-aware operations.

Why: the first pass removes annotation blocks from logical path segments and records them in `tag-list`. A second pass reads the cleaned names and overwrites every leaf's useful list with empty tag-sets.

Avoid it: retain the already-resolved tree instead of calling `resolve-tags` again.
