# VFS data model

The two shapes everything under `mlem.vfs` operates on: the **node tree** and the **path**.

## Node

A node is an attrset — either a **leaf** (a file) or a **directory** (a subtree). Classified in [src/vfs/node-cond.nix](../src/vfs/node-cond.nix):

| predicate | returns |
|---|---|
| `is-leaf path node` | `true` when the node has a string `text`, a string-or-derivation `src`, or is itself a derivation |
| `is-dir path node` | `true` when every value is an attrset (so `{}` is a directory) |
| `is-leaf-node path node` | `true` for a leaf, `false` for a directory, **throws** otherwise — this is the `cond` the traversals use |

Leaf fields:

| field | type | meaning |
|---|---|---|
| `text` | string | file contents, in memory |
| `src` | string \| derivation | location of the real file on disk |
| `tags` | list of attrsets | tags parsed from the filename, present after `resolve-tags` (see [test-naming.md](test-naming.md)) |

A directory maps a path segment to a child node:

```nix
{
  "A.txt" = { text = "contents of A.txt"; };   # leaf, in memory
  "B.css" = { src = "/nix/store/…-dir/B.css"; };  # leaf, on disk
  sub = { "C.txt" = { text = "…"; }; };        # directory: key = segment, value = node
}
```

A bare derivation is treated as a leaf, so traversals stop on it instead of recursing into its cyclic attrs. [materialize](../src/vfs/dir/materialize.nix) rewrites every leaf to `{ src = <store-path>; }`.

## Path

A path is a **list of segments**, not a string; the last segment is the file name.

```nix
["A" "B" "C.txt"]
```

Conversions: [from-str](../src/vfs/path/from-str.nix) (`"A/B/C.txt"` → `["A" "B" "C.txt"]`) and `get.str` (`["A" "B"]` → `"A/B"`).

Accessors mirror as getters ([getters.nix](../src/vfs/path/getters.nix)) and setters ([setters.nix](../src/vfs/path/setters.nix)); all take the path last so they compose in a pipe:

| getter | result on `["A" "C.txt"]` | setter | effect |
|---|---|---|---|
| `get.name` | `"C.txt"` | `set.name "x"` | replace the last segment |
| `get.stem` | `"C"` | `set.stem "x"` | replace the stem, keep the ext |
| `get.ext` | `"txt"` (or `""`) | `set.ext "x"` | replace the ext (`""` drops it) |

Stem/ext split on `.` with the **last** component as the ext: `archive.tar.gz` → stem `archive.tar`, ext `gz`.

## Traversals

`mlem.vfs.dir.{walk, collapse, reform, filter, materialize, path-strs}` recurse while a node is a directory and stop at leaves, using `is-leaf-node` as the `cond`. A malformed node (neither leaf nor directory) throws with its path instead of overflowing the stack.
