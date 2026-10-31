# Materializing a VFS tree

How a VFS tree becomes a store object a builder can consume. The payload model is defined in [data-model.md](data-model.md); this doc covers the physical step.

## Two actions, chosen by payload state

| leaf state | action |
|---|---|
| authored (`text`) | write the string |
| opaque (`origin`) | copy the file, dereferencing a hand-built symlink origin |

The branch is presence-based (`node ? text`), so there is no heuristic. An authored leaf outranks its own `origin`, which is what makes `edit` reliable.

The result is `{ drv, tree }`: the store object, and a VFS index whose leaves are opaque and point inside it. Materialization drops the payload and empty branches, so a second pass is a copy rather than a rewrite.

`tag-list` is the one field that survives. It describes the logical path, and materialization does not change a path; dropping it would make `select-by-tag`, `filter-within-tag`, and `walk-within-tag` unusable on a materialized tree, and the tags cannot be recovered afterwards because `resolve-tags` strips the `{…}` annotations out of the segments themselves. Everything else — `expr` above all — is dropped: it was computed from the old `origin`, so carrying it forward would mean carrying a value that no longer describes the bytes.

## One copy per leaf

Each opaque leaf is copied independently, and each authored leaf is written independently. The copy does not need the enclosing tree, because no leaf depends on a sibling:

- An out-of-store `origin` is normalized through [`to-store-str`](../src/path/to-store-str.nix) first, which calls `builtins.path` on that single path.
- A store-resident `origin` becomes a string that keeps its store object alive: a path is converted, a string is returned unchanged, and a context-free string gains context on its store root. The builder copies it with the builtin `cp`.

`-L` matters only for a hand-built leaf whose `origin` is a link, since ingest rejects links; see [Links that remain possible](#links-that-remain-possible).

## One strategy: build a tree

Materialization always produces a derivation. The plan is built in eval and passed as [structured attributes](../src/vfs/tree/materialize.nix): one JSON record per leaf, carrying the destination directory, the file name, and a store path for the bytes. The builder is nushell, and it only replays that plan:

```nu
mkdir $out
for $entry in $attrs.data {
  mkdir ([$out $entry.dir] | path join)
  cp $entry.src ([$out $entry.dir $entry.file] | path join)
}
```

Two consequences of transporting the plan as data rather than as shell text:

- **No quoting, no argument splitting.** Names travel as JSON strings and become paths through `path join`, so a name with `$`, a quote, a space, or a leading `-` needs no escaping and cannot be reinterpreted. The retired shell version had to pass every name through `lib.escapeShellArg` and every command through `--`.
- **No string building.** The plan is a list, not a concatenated command line, so cost is linear in the number of leaves.

Authored content travels through `builtins.toFile`, so the derivation expression carries store paths instead of contents. `toFile` also registers its references correctly when content embeds a store path. The script goes through `toFile` as well, since it embeds no store path.

The copy is nushell's builtin `cp`. It dereferences a file link and rejects a directory link, which matches the model: a leaf is a file. One property to know: for a dangling or cyclic link the builtin reports the error and still exits `0`, so such a leaf would be dropped and the build would still succeed. That is unreachable from [from-src](../src/vfs/tree/from-src.nix), which rejects every symlink, and is only a hazard for a hand-built leaf whose store-resident `origin` is itself a broken link.

Opaque bytes are copied, authored bytes are written, and the executable bit comes from the source the same way it would from a plain `cp`.

## Why there is no evaluation-time shortcut

A tree with no authored leaf and no content changes could in principle be copied at evaluation time (`builtins.filterSource` or `lib.fileset.toSource`), skipping the derivation. Materialization does not do that, for three reasons.

- **Such a tree does not need the library.** A pure copy is the source path. Calling `materialize` to obtain what was already a store object is circular; the caller passes the path instead.
- **The check is not cheap.** Deciding "nothing authored, nothing rewritten" requires walking the entire tree and confirming no leaf carries `text`. That is more work than the derivation it would avoid.
- **The work that remains is why the library exists.** Generated leaves, path rewrites, tag resolution, and merges from several roots are exactly the cases that reach `materialize`; none of them is a pure copy.

`filterSource` is still the right tool for a caller who genuinely only needs a copy; it is just not a branch inside `materialize`. It preserves nesting, the executable bit, symlinks, and empty directories, and it exposes each entry's type to its filter.

None of the type probes read a file: `builtins.readFileType` and `builtins.readDir` are `lstat`, so a fifo, socket, or device is reported as `unknown` instantly and never opened. `readDir` is the cheaper probe in a tree walk — one call per directory returns every entry's name and type — which is why `lib.filesystem.listFilesRecursive` uses it, discarding the type. `builtins.readFile` is the only thing that opens a file, and on a fifo it blocks forever.

## Measured cost

Small files, warm store, local daemon, this machine:

| strategy | 1000 files |
|---|---|
| `filterSource` (eval-time copy) | ~50 ms |
| one builder invocation with `cp` | ~473 ms (≈444 ms nix overhead, ≈29 ms copying) |
| 20 separate derivations | ~843 ms → ≈20 ms each |
| `builtins.toFile`, 1000 calls | ~18 ms |
| `lib.escapeShellArg` on 100 KB (retired path) | aborts (`stack overflow`) |

The fixed overhead of one derivation is about 0.4 s, independent of tree size. It is paid once per materialized tree, which is the same order as any real build consuming that tree.

## Why not one derivation per file

Per-file derivations buy partial rebuild of the *output*, but the tree is a single store object: changing one byte produces a new tree path, so every consumer of the tree rebuilds regardless. Per-file granularity only avoids re-copying unchanged files, which costs microseconds. In exchange it adds a derivation, a log line, and a store object per file, at ≈20 ms each — about 600× the cost of copying a file.

Per-file derivations pay off only when consumers depend on individual files rather than on the tree, such as a shared library consumed by several packages. That is a consumer-side selection problem, not a reason to split every tree.

## Copy tools, and what they preserve

| tool | modes | symlinks | empty dirs | references |
|---|---|---|---|---|
| `cp -L` in a builder (used here) | preserved | collapsed | preserved | scanned from output |
| nushell builtin `cp` (used here) | preserved | file links collapsed, directory links rejected | n/a | scanned from output |
| `cp -a` in a builder | preserved | preserved | preserved | scanned from output |
| `builtins.path` on a single path | preserved | collapsed | n/a | **none** |
| `builtins.path` on a directory | preserved | preserved | preserved | **none** |
| `builtins.filterSource` | preserved | preserved | preserved | **none** |
| `lib.fileset.toSource` | preserved | preserved | **dropped** | **none** |

The fixed-output copies are not scanned for store paths, so a preserved link to `/nix/store/…` registers no dependency and does not hold its target from garbage collection. A derivation output is scanned. Dereferencing makes the question moot: the bytes are self-contained.

## Non-regular entries are rejected at ingest

`builtins.readFileType` reports four kinds: `regular`, `directory`, `symlink`, and `unknown`, where `unknown` is the catch-all for fifo, socket, and device. The check sits in the primitive, [file.from-src](../src/vfs/file/from-src.nix): it accepts only `regular` and throws for the rest, naming the VFS path and the kind. [tree.from-src](../src/vfs/tree/from-src.nix) is a combinator over it and inherits the rejection.

A fifo, socket, or device is rejected because there is nothing to represent: the store carries regular files and directories, so such an entry has no bytes to copy and no shape to store. Deferring it is also the worst option — `cp` opens a fifo and waits forever, and `builtins.readFile` does the same.

A link is rejected for a stronger reason. `builtins` has no `readlink`, so eval cannot see where it points, and every alternative breaks the contract:

| option | why not |
|---|---|
| dereference | a relative target can point above the root and an absolute one names mutable host state, so the same tree yields different bytes on different machines |
| preserve | the output is meant to be self-contained bytes; a pointer keeps it dependent on a context that can disappear |
| keep as a node | the leaf then has no byte stream, and a later `read` or copy fails on it |

Rejection is free: `readFileType` is `lstat`, so no file is opened and no store copy is made.

## Links that remain possible

A hand-built leaf can carry an `origin` that is a link, since ingest is not the only producer. The builtin `cp` dereferences a file link, and the consequences belong to the caller:

- `to-store-str` follows a working-copy link and freezes the target's current bytes, so a link to `/etc/hostname` snapshots host state; a store-resident link to such a path fails in the sandbox instead.
- A working-copy dangling link fails in `to-store-str` naming the target, uncatchably.
- A store-resident dangling or cyclic link is **dropped silently**: the builtin prints the error and exits `0`, so the build succeeds without the file. A leaf is expected to be a regular file, and ingest guarantees that.
- Duplicated content is accepted; the store is content-addressed, so `libfoo.so -> libfoo.so.1` costs size, not correctness.

## Current implementation

[materialize.nix](../src/vfs/tree/materialize.nix) matches the per-leaf strategy:

- it collapses the tree into one JSON record per leaf and rebuilds `tree` from those records, so empty branches disappear, every leaf is opaque, and `tag-list` is the only field carried over;
- it validates every path with [`path.validate`](../src/vfs/path/validate.nix) before the record is made, so `..` and `/` cannot reach the builder;
- non-regular entries never reach it from ingest; [file.from-src](../src/vfs/file/from-src.nix) rejects them by `readFileType`;
- it normalizes an out-of-store `origin` through [`to-store-str`](../src/path/to-store-str.nix) before the copy;
- a hand-built link is dereferenced in both the working-copy path and the builder path;
- authored content goes through `builtins.toFile`, so the plan carries a store path and the bytes never enter the derivation expression;
- names travel as JSON and are joined with `path join`; no shell quoting exists in this path.

Why `toFile` rather than passing content through the command: the retired shell version wrote content with `printf` after `lib.escapeShellArg`, which aborted with `stack overflow` at 100 KB and grew the derivation one-for-one with the content (51 KB of `.drv` for 50 KB). With `toFile` the same file produces a 1.7 KB derivation.
