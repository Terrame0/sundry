# Gotchas

These are counter-intuitive mechanics that can silently invalidate an otherwise plausible change.

## Traversal strictness depends on the family

Rule: distinguish structural traversal from forcing the values produced by callbacks.

Why: `walk` is branch-lazy, while evaluating `collapse`, `reform`, or `filter` forces their complete traversal structure. Nested replacement values and leaf payload fields can remain lazy in every family. [attrs-traversal.md](attrs-traversal.md#terminal-nodes) gives the exact boundaries.

Avoid it: use [`sundry.does-throw`](testing.md#does-throw-does-not-catch-everything) when the question is whether the **entire result, including payload**, evaluates. For VFS structure-only validation without forcing lazy `expr`, deeply force a payload-free projection such as `sundry.vfs.tree.path-strs tree` or `sundry.vfs.tree.collapse (_: _: null) tree`.

## Leaf recognition forces `text` unless `origin` is tested first

Rule: keep the `origin` checks before the `text` check in [`is-leaf`](../src/vfs/node/is-leaf.nix).

Why: `builtins.isString text` forces `text` to weak head normal form. `sundry.vfs.node.halt` is the `halt` of every VFS traversal, including structure-only ones such as [`path-strs`](../src/vfs/tree/path-strs.nix) and the [`dirs`](../src/attrs/merge-resolvers/dirs.nix) merge resolver; `||` short-circuits, so testing `origin` first recognizes a leaf from its path/string/derivation literal and never evaluates `text`. This keeps those traversals from being a forcing point, whether `text` is an in-memory literal or a thunk that `edit` produced.

Avoid it: do not reorder the disjunction to test `text` first, and do not add a construction-time type check on `text` to a builder such as [`from-text`](../src/vfs/file/from-text.nix). Any `assert lib.isString text` forces `text` at assembly. The leaf type gate is [`is-leaf`](../src/vfs/node/is-leaf.nix); leave validation to the classifier. Ingest does not attach `text` at all, so the only `text` in a tree is authored content.

The trade-off: without the assert, `from-text ["A"] {}` builds `{A = {text = {};};}`, which the node model classifies as a **directory**, not a malformed leaf (see [data-model.md](data-model.md)). The classifier rejects scalar non-string `text`, but an attrset-shaped one becomes a directory.

## Rebuilding traversals lose traversable empty attrsets

Rule: do not use `collapse`, `reform`, or `filter` when an unhalted empty attrset must survive as a structural node.

Why: recursive `collapse` emits no terminal for `{}`. `reform` and `filter` rebuild their result from those emitted terminals, so they also lose that branch. `walk` maps the existing shape and preserves it. In VFS, `{}` is a valid empty directory, making this difference observable.

Avoid it: use `walk`, make the empty attrset terminal through `halt`, or restore required empty branches explicitly.

The physical VFS roundtrip is file-oriented too: `dir.from-src` discovers files, so a physical empty directory never becomes a node, and `materialize` creates only the parents needed by files. An empty branch that exists in a tree is preserved by structure-only operations, but it has no bytes to carry through a copy. Empty directories are out of scope by contract ([vfs-model-stories.md](vfs-model-stories.md#us-13--empty-directories-are-not-part-of-the-model)).

## `reform` collision handling is structural, not VFS-aware

Rule: do not assume overlapping target paths from `reform` produce a clean VFS collision error.

Why: reform fragments are combined with `recursive.no-collision`. Two attrset fragments recurse and can combine before terminal fields collide. A valid leaf discriminator then takes precedence over the merged directory fields, so a leaf can silently hide a subtree rather than fail validation.

Avoid it: detect incompatible terminal overlaps before rebuilding. For VFS, do not emit two leaves at one target or make a leaf target the ancestor of another emitted path. Shared directory prefixes are safe. A later VFS traversal catches malformed rebuilt nodes, but cannot detect a hidden subtree once `text` or `origin` makes the combined attrset a valid leaf.

## `dirs` validates collisions only

Rule: use a separate traversal when complete input-tree validation is required.

Why: merge resolvers run only where two inputs contain the same key. A unique malformed branch passes through `sundry.attrs.merge.dirs.*` unchanged.

Avoid it: deeply force `sundry.vfs.tree.path-strs tree` or `sundry.vfs.tree.collapse (_: _: null) tree` when validation outside merge-relevant collisions matters. These projections validate node structure without forcing leaf payload such as `expr`.

## Path values copy to the store under most string operations

Rule: convert a path to a string only with `builtins.toString`; never hand a path to another string builtin.

Why: Nix's path-to-string coercion defaults to `copyToStore = true`, so several string builtins copy the file into `/nix/store` under its basename before returning. A basename that is not a legal store name then aborts evaluation — which is what a `lib.hasSuffix ".nix"` filter over `listFilesRecursive` of a path literal hits on a name such as `что?`. [assembly.nix](../assembly.nix) sidesteps it by testing `baseNameOf path`.

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

Why: a string that carries store context — e.g. `"${self.outPath}/..."`, since interpolating a path yields a context-carrying string — keeps that context through `toString`, `removeSuffix`, `splitString`, and `removePrefix` (which preserves the context of the sliced string, not of the prefix). Building module paths with `lib.filesystem.listFilesRecursive "${self.outPath}/src"` therefore leaves each path segment carrying the source store path, and Nix rejects it as an attribute name: `the string 'attrs' is not allowed to refer to a store path`. Iterating with a path value (`listFilesRecursive ../src`) avoids this, because `builtins.toString` on a path is context-free. `flake-dir` is itself a path (`./.`), so `flake-dir + "/src"` is a context-free path; only interpolation (`"${flake-dir}/src"`) would copy it to the store and reintroduce the context.

Avoid it: iterate path values and derive names with `toString`; when the input is already a context-carrying string, discard explicitly with `builtins.unsafeDiscardStringContext`. [from-str.nix](../src/vfs/path/from-str.nix) normalizes both cases this way.

## Content class is not detectable in eval

Rule: never infer "text or binary" from bytes; ingest is opaque and decoding is an explicit request.

Why: `readFileType` returns `regular` for an ELF binary and for a Markdown file alike, and the only in-eval signal is the absence of NUL — but that check *is* `readFile`, whose failure (`the contents of the file '…' cannot be represented as a Nix string`) is an evaluator error that neither `builtins.tryEval` nor [`sundry.does-throw`](../src/does-throw.nix) catches. `builtins` has no size, `stat`, or prefix read, so magic-byte sniffing is unreachable: `readFile` decodes the whole file before returning anything. Non-UTF-8 is not a signal either — Nix strings are byte strings and `\xff\xfe\x01` round-trips; the boundary is exactly `0x00`. A `runCommand` probe (compare `wc -c` with `tr -d '\0'`) does classify correctly but is IFD: one build per file at eval time, rejected under `--pure-eval`.

Avoid it: keep ingest opaque, so no classification is needed at all. A leaf has `origin` and is copied byte-for-byte; a consumer that wants text calls `sundry.vfs.file.read` and accepts the decode risk at that point, and `edit` promotes the result to authored content. See [vfs-model-stories.md](vfs-model-stories.md#us-24--never-classify-content).

## A hand-built path segment can escape the output

Rule: build paths through `from-str` or validate them; a segment is not safe just because it is a valid attribute name.

Why: a directory node's attribute names become path segments directly, and `..` is a legal Nix attribute name. Joining it produces `$out/../A.txt`, so the file is written outside `$out`. Under the sandbox that write lands in the chroot store and is discarded: the build still succeeds, because `mkdir -p "$out/.."` created `$out`, and the leaf is simply missing. A segment containing `/` fails differently — `mkdir` creates only the directories implied by the segment list, then `cp` cannot open the deeper destination. Neither case is reported by the store.

Avoid it: go through [from-str](../src/vfs/path/from-str.nix), which rejects `""`, `.`, `..`, and `/`, or call [`sundry.vfs.path.validate`](../src/vfs/path/validate.nix) on a list you assembled yourself. [materialize](../src/vfs/tree/materialize.nix) re-validates every leaf path before it becomes a command.

## A symlink anywhere under a root aborts the whole ingest

Rule: do not point [from-src](../src/vfs/tree/from-src.nix) at a tree containing links, and do not keep a link fixture inside a directory that a test ingests wholesale.

Why: the ingest primitive accepts only a regular file, so a single link that `dir.from-src` enumerates as a leaf throws for the entire tree, not just for that path. That is the point of the contract, but it makes "ingest the repository root" a fragile test: one symlink fixture anywhere below it — checking in `result` from a build, a vendored `node_modules` with links — breaks it. The `get-relative-to` tests therefore root at `flake-dir + "/src"` rather than the flake root.

Avoid it: ingest the narrowest directory that has what you need, and keep link fixtures in a tree that only the rejection test touches.

## Nushell's builtin `cp` exits `0` when a link dangles

Rule: do not read a success from nu's builtin `cp` as "the file arrived" when the source may be a link.

Why: the builtin prints `nu: cp-error-cannot-stat` for a dangling link and `Too many levels of symbolic links` for a cyclic one, and in both cases exits `0`; a missing regular path exits `1`. A builder that trusts the exit code then succeeds with the file absent — measured: the output directory came out empty and the derivation was accepted as valid. `materialize` uses the builtin, so it inherits this, which is harmless only because ingest rejects every symlink: a tree from [from-src](../src/vfs/tree/from-src.nix) holds no link. The reachable case is a hand-built leaf whose store-resident `origin` is itself a broken link; a working-copy one fails earlier, inside `to-store-str`.

Avoid it: if a tree can carry link origins, copy with `^${pkgs.coreutils}/bin/cp -L -- …` instead, which exits non-zero for both cases. Note that `builtins.toFile` refuses a script embedding that path, because the content would reference a derivation; such a script needs `pkgs.writeText`.

## `readFile` follows symlinks and its failures are uncatchable

Rule: never decide "not a directory, therefore a regular file" before reading; and never assume a hand-built `origin` names a regular file.

Why: `builtins.readFile` dereferences a symlink, so reading an opaque leaf that is a link yields its target's bytes. When the link does not resolve, the error names the **target**, not the link (`path '/…/nowhere' does not exist`), and it is an evaluator error: neither `builtins.tryEval` nor [`sundry.does-throw`](../src/does-throw.nix) catches it. A link to a directory fails the same way. A fifo is worse — `readFile` opens it and blocks forever, so one `read` on a fifo hangs evaluation. Type probes are safe: `builtins.readFileType` and `builtins.readDir` are `lstat` and report a fifo as `unknown` without opening it (`readFileType` on a dangling link still returns `"symlink"`).

Avoid it: [file.from-src](../src/vfs/file/from-src.nix) rejects `symlink` and `unknown` entries by `readFileType`, so an ingested leaf always has a byte stream and an explicit `sundry.vfs.file.read` is safe. A hand-built leaf can still point at a link: materialization dereferences it with `to-store-str`/`builtins.path` (working copy, resolved on the host) or `cp -L` (store-resident, resolved against siblings).

## Evaluation-time copies register no references

Rule: do not preserve a symlink to `/nix/store/…` in a tree copied by `builtins.path`, `builtins.filterSource`, or `lib.fileset.toSource` and expect the target to survive garbage collection.

Why: those copies are fixed-output objects, so Nix stores their bytes without scanning them for store paths. A tree containing `link -> /nix/store/…-foo/bin/foo` gets `references = []` and `deriver = null`; collecting `foo` leaves a dangling link. A derivation output *is* scanned, so the same link in a `runCommand` result creates a reference and holds `foo` alive. The copy is byte-identical either way, which makes the difference invisible until a GC run.

Avoid it: never rely on a preserved link for a dependency. Ingest rejects links, and materialization dereferences a hand-built one, so the output holds bytes and needs no reference. If a pipeline copies a tree at evaluation time for some other reason, dereference there too or accept that the link holds nothing alive.

## Authored `text` silently outranks `origin`

Rule: write `text` only through `edit`; never store the result of a read.

Why: a leaf's payload state is presence-based, and `text` wins over `origin` at materialization. That is what makes `edit` reliable, but it also means `file // {text = readFile file.origin;}` silently converts a copy into a rewrite: the bytes move into the derivation, the executable bit is lost, and an unrelated `origin` shows a location that no longer describes the payload. The reverse mistake is just as quiet: rewriting `text` while dropping the node's `text` field reverts the leaf to opaque and discards the edit.

Avoid it: use `sundry.vfs.file.read` to read and `sundry.vfs.file.edit fn` to write. When a transformation rewrites contents, route it through `edit`; when it only moves paths or tags, preserve the fields verbatim.

## Per-file store copies break relative imports

Rule: never materialize a single `.nix` file with `builtins.path` / interpolation and then `import` it; copy the whole tree instead.

Why: `import` resolves a relative import such as `import ./b.nix` against the importing file's own directory. A per-file `builtins.path { path = ./a.nix; name = "a.nix"; }` lands the copy in the store root, so `./b.nix` is looked up beside the store object: `error: 'b.nix' is too short to be a valid store path`. The tree-level copy from [materialize](../src/vfs/tree/materialize.nix) keeps siblings together and is unaffected.

Avoid it: keep tree-structured sources as path values and let [`dir.materialize`](../src/vfs/tree/materialize.nix) copy the whole tree, or copy a whole directory (`builtins.path { path = ./dir; }`). [`to-store-str`](../src/path/to-store-str.nix) leaves a path already inside the store in place — as a context-carrying string pointing at its top-level store object, without copying — so it never breaks relative imports for store-resident files; it copies only paths outside the store. A store-prefixed **string** is returned unchanged, except that a context-free one gains the same context on its store root; a string that already carries context passes through untouched, so an unbuilt derivation output is not forced — `appendContext` checks that its path exists or can be substituted. A **derivation** is coerced with `toString` to its output path, whose context names the `.drv` and its `out` output; that also does not force the build. [`store-root`](../src/path/store-root.nix) returns that top-level object (`/nix/store/<hash>-name`) and [`strip-store`](../src/path/strip-store.nix) returns the path relative to it (`/src/f.nix`).

This is why [`file.from-src`](../src/vfs/file/from-src.nix) stores its `fs-path` unchanged instead of normalizing `origin` to a store string: `origin` is the exact value [`load-nix-with`](../src/vfs/tree/load-nix.nix) feeds to `import`, so a per-file copy there would turn every relative import in a loaded `.nix` into the error above. Normalizing `origin` at construction time plants a mine under the loader; the raw path keeps the tree intact until a stage that legitimately copies it whole.

Opaque materialization is not affected the same way, because it dereferences a hand-built link instead of preserving it: `builtins.path` on a single symlink follows it, and `cp -L` follows a store-resident one against its siblings in the same store object. A preserved link, by contrast, would dangle.

## `vfs.tree.get-relative-to` needs the root the tree was built from

Rule: pass the tree's root explicitly — `get-relative-to root path dir` — and give a path (value or string) under that root. The function strips `root` and looks the remainder up in `dir`. A path outside `root` throws.

Why: a VFS tree carries no record of its own filesystem root. Leaves have `origin`, but directories do not, so the root cannot be recovered from the tree. Guessing it from `builtins.storeDir` (the previous behaviour) worked only when the tree had been built from a store object and the query path belonged to the same object; a working-copy tree or a merged tree silently produced wrong segments. With an explicit root, one code path covers store and non-store trees alike: `get-relative-to root ./config dir` works whether `root` is `./.` or a store copy.

Store paths are not special. `builtins.storeDir` is not consulted; a store tree is just a tree whose root happens to be a store object. When a tree is merged from several sources (`vfs.tree.merge`), pass the root the target node came from — a query under a different source resolves to the wrong (or no) node. The function warns when the found node's `origin` lies outside `root`, but still returns the node.

Avoid it: build the query from the same root you pass; use `root + "/relative/path"` (a path value) rather than interpolating. A trailing `/`, an empty-segment path, and `root` itself all throw; a missing node throws a catchable `throw` (not `abort`). VFS-relative strings (`"/src/f.nix"`) and segment lists are rejected — they duplicate attribute access, so use `sundry.attrs.get` or `dir.src.f` instead.

`get-relative-to` strips tag annotations (`{...}`, via [`strip-between`](../src/vfs/path/strip-between.nix)) from a query segment when the cleaned path exists in `dir`, so an annotated segment such as `network{modules:system}` resolves against a `resolve-tags`-cleaned tree. It falls back to the raw segment when the cleaned path is absent, so the same call also works on an unresolved tree whose keys still carry annotations. `origin` keeps its annotations regardless.

## `origin` accepts a derivation, and external stages rely on it

Rule: do not narrow the accepted `origin` types to what `sundry`'s own constructors produce; `is-leaf` must keep accepting a derivation.

Why: the node contract is public, and downstream pipelines build derivation origins themselves. [`file.from-src`](../src/vfs/file/from-src.nix) emits a path or string origin, but [`materialize`](../src/vfs/tree/materialize.nix) drops `text`, and a later [`reform`](../src/vfs/tree/reform.nix) can set `origin` to a build derivation — producing a derivation-only leaf. Dropping `lib.isDerivation origin` from [is-leaf](../src/vfs/node/is-leaf.nix) makes such a node neither leaf nor directory, so `sundry.vfs.node.halt` throws (`... is neither a leaf nor a directory`) on a tree that previously worked.

Avoid it: treat a node with a derivation `origin` as a leaf. When auditing which types a field may hold, check external consumers, not only the in-repo constructors; a library's field contract outlives the call sites visible here.

## `resolve-tags` throws on an already-resolved tree

Rule: resolve annotations once, before tag-aware operations.

Why: the first pass removes annotation blocks from logical path segments and records them in `tag-list`. A second pass has no annotations left to read and would overwrite every leaf's useful list with empty tag-sets, so `resolve-tags` throws per leaf that already carries `tag-list`.

Avoid it: retain the already-resolved tree. To hand a tree to another owner, neutralize it with [`strip-tags`](../src/vfs/tree/strip-tags.nix), which removes the annotations and the `tag-list` instead of re-resolving.

## Negative string indices are labels, not Python normalization

Rule: keep a negative index signed through the `range` walk; resolve it to a cell only in [`at`](../src/str/at.nix).

Why: Python rewrites `-k` to `len-k` before comparing it against the start, so `"abcdefgh"[5:-1:-1]` is `""`. Here the label stays `-1` and `slice [5 (-1) (-1)] "abcdefgh"` walks `5,4,3,2,1,0` to `"fedcba"`. The reverse and mixed slices `[2 (-1) (-1)]` and `[1 (-2) (-1)]` depend on that sign surviving the walk. Pre-normalizing a bound with `len+i`, or making `at` normalize before the sign check, silently turns them empty or wrong. The full model is in [str-indexing.md](str-indexing.md).

Avoid it: build ranges from signed labels and let `at` resolve the sign last. Do not add modular wrap — an out-of-range label must `throw`.
