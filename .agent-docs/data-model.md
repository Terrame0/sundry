# VFS data model

The two shapes everything under `sundry.vfs` operates on: the **node tree** and the **path**.

## Node

A valid node is an attrset — either a **leaf** (a file) or a **directory** (a subtree). Classified under [`sundry.vfs.node`](../src/vfs/node/):

| predicate | returns |
|---|---|
| `sundry.vfs.node.is-leaf path node` | `true` when the node has a string `text` or a path-, string-, or derivation-typed `origin` |
| `sundry.vfs.node.is-opaque path node` | `true` when the node is a leaf without `text`, i.e. its bytes exist only at `origin` |
| `sundry.vfs.node.is-dir path node` | `true` when the node is not a leaf and every value is an attrset (so `{}` is a directory) |
| `sundry.vfs.node.validate path node` | `true` for a well-formed node; **throws** for a non-attrset or a node that is neither a leaf nor a directory |
| `sundry.vfs.node.halt path node` | the traversal `halt`: classifies the node once and returns `true` for a leaf and `false` for a directory, **throwing** otherwise |

Leaf fields:

| field | type | meaning |
|---|---|---|
| `text` | string | authored contents; **authoritative over `origin`** |
| `origin` | path \| string \| derivation | the file's physical location; the bytes to copy when `text` is absent |
| `tag-list` | list of attrsets | root-to-leaf tags, exactly one attrset per original path segment; written by `resolve-tags`, removed by `strip-tags` |
| `expr` | any Nix value | lazy imported or derived payload attached by `load-nix` / `load-nix-with` |

A leaf is in exactly one of two payload states:

| state | fields | meaning | materialization |
|---|---|---|---|
| **opaque** | `origin` | bytes exist only at `origin`; eval never read them | copy `origin` as-is |
| **authored** | `text`, optionally `origin` | `edit` or `from-text` supplied the contents | write `text` |

Because the states are distinguished by presence, `text` is not a cache: it is a declaration that the bytes came from Nix and outrank `origin`. Nothing attaches `text` except authoring operations, and no read path stores it. This makes the two states unambiguous — there is no "lazy text that might be a view or an edit", so `materialize` needs no heuristic: `text` present means authored, absent means copy `origin`.

`origin` is provenance in both states; an authored leaf keeps it so downstream can still tell where the file came from, but the bytes come from `text`.

Reading is a function, not a field:

```nix
sundry.vfs.file.read :: file -> text
```

It returns `file.text` when the leaf is authored and otherwise a lazy `builtins.readFile file.origin`. The thunk is returned, never stored, so reading does not change the node's state. Reading an opaque leaf is therefore a deliberate act by the consumer and carries its own costs (NUL aborts, fifo blocking, symlink dereference — see [gotchas.md](gotchas.md#readfile-follows-symlinks-and-its-failures-are-uncatchable)).

Authoring is leaf-level:

```nix
sundry.vfs.file.edit :: (text -> text) -> file -> file
```

It sets `text = fn (read file)` and keeps `origin` so provenance survives the edit. Every operation that changes contents goes through `edit`; no transformation rewrites `text` in place while leaving an `origin` that still describes the old bytes.

Both take a leaf, not a path, and are applied per leaf by a tree-level traversal. Neither can name a VFS path in an error, so callers reach them through `is-leaf` or `halt`; on a non-leaf, `read` fails on the missing attribute rather than reporting a node type. `read` takes the file last and `edit` takes the function first, matching the data-last convention used by the other `vfs.file` helpers.

Entry kind is not a field, but it is constrained at ingest. The leaf primitive, [`file.from-src`](../src/vfs/file/from-src.nix), accepts only an entry whose `builtins.readFileType` is `regular`; a link, fifo, socket, or device throws with the entry's VFS path ([vfs-model-stories.md](vfs-model-stories.md#us-12--symlinks-are-out-of-scope)). The directory combinator only adds recursion, so in an ingested tree every leaf has a byte stream. Directory-ness stays structural, and a hand-built leaf whose `origin` is a link is dereferenced by materialization as the caller's own input.

Leaf recognition takes precedence over every other field. Once `text` or `origin` has a valid leaf type, the complete attrset is terminal and traversal does not inspect any child-shaped metadata inside it. This keeps a lazy `expr` payload from being forced. `expr` itself is not a discriminator: an attrset-valued expression must remain distinguishable from a directory containing a child segment named `expr`.

A directory maps a path segment to a child node:

```nix
{
  "A.txt" = { origin = "/…/A.txt"; };                      # opaque: copied
  "B.css" = { origin = "/…/B.css"; text = "…"; };          # authored: text wins
  "C.nix" = { origin = "/…/C.nix"; expr = v: v + 1; };     # opaque, lazy import
  sub = { "D.txt" = { text = "…"; }; };                    # generated, no origin
}
```

Without a valid leaf discriminator, every value must itself be an attrset for the node to be a directory. Consequently `{}` is a directory, `{ text = {}; }` is a directory containing an empty child directory under the segment `text`, and `{ unexpected = 1; }` is malformed. `sundry.vfs.node.validate` reports malformed nodes with their VFS path.

Field-producing transformations and their preconditions are documented in [vfs-lifecycle.md](vfs-lifecycle.md). The construction of `tag-list` is documented separately in [tag-resolution.md](tag-resolution.md), and its query semantics live in [tag-matching.md](tag-matching.md).

Ingest implements the opaque half of this contract and enforces the entry-kind boundary; [vfs-model-stories.md](vfs-model-stories.md) tracks what remains (empty directories are out of scope).

## Path

A path is a **list of segments**, not a string; the last segment is the file name.

```nix
["A" "B" "C.txt"]
```

Conversions: [from-str](../src/vfs/path/from-str.nix) (`"A/B/C.txt"` → `["A" "B" "C.txt"]`) and `get.str` (`["A" "B"]` → `"A/B"`).

Segments are validated, not assumed safe: [`sundry.vfs.path.validate`](../src/vfs/path/validate.nix) rejects `""`, `.`, `..`, and any segment containing `/`, and returns the path unchanged so it composes in a pipe. [from-str](../src/vfs/path/from-str.nix) runs it, and [materialize](../src/vfs/tree/materialize.nix) re-runs it per leaf, since attribute names become segments without passing through the parser.

Accessors mirror as getters ([getters.nix](../src/vfs/path/getters.nix)) and setters ([setters.nix](../src/vfs/path/setters.nix)); all take the path last so they compose in a pipe:

| getter | result on `["A" "C.txt"]` | setter | effect |
|---|---|---|---|
| `get.basename` | `"C.txt"` | `set.basename "x"` | replace the last segment |
| `get.stem` | `"C"` | `set.stem "x"` | replace the stem, keep the ext |
| `get.ext` | `"txt"` (or `""`) | `set.ext "x"` | replace the ext (`""` drops it) |

Stem/ext split on `.` with the **last** component as the ext: `archive.tar.gz` → stem `archive.tar`, ext `gz`.

The tree root is always a directory container, never a leaf at `[]`. File constructors therefore require a non-empty path. VFS directory traversals specialize the generic contract from [attrs-traversal.md](attrs-traversal.md) with `sundry.vfs.node.halt` as `halt`.
