# Tag matching

How a **tag-spec** queries a file's tags. The tag shape itself — `tag-list`, a per-path-level list of tag attrsets — lives in [data-model.md](data-model.md); this doc is the query semantics over it.

## A spec matches one tag-set: presence and value

The [`tag`](../src/boolean/operands/tag.nix) operand of [boolean.expr](../src/boolean/expr.nix) takes a `tag-spec` and matches it against the bound `tag-set` (one `{ key = value; }` attrset), returning a bool. Every key in the spec must be **present** in the tag-set; its value entry then says which values count as a match:

| spec entry | the tag-set passes when |
|---|---|
| `key = "1"` or `key = ["1" "2"]` | `key` present **and** values intersect (`∩ ≠ ∅`) |
| `key = []` | `key` present, any value (wildcard) |

Keys combine with **AND** across the spec. Within one key the value list combines with **OR** (hit at least one). Every key still requires presence regardless of its value list. This is faceted-filter semantics: AND across facets, OR within a facet.

Value matching is set **intersection** ([list.intersect](../src/list/intersect.nix)), not subset: a file tag `hosts = ["desktop" "laptop"]` matches `hosts = "desktop"` because they overlap. Value terms are *additive* — more file values never drop a match. Negation — forbidding a value or requiring a key **absent** — is expressed at the expression level via [boolean.expr](../src/boolean/expr.nix), not inside the spec: `!(tag { key = []; })` matches when `key` is absent.

## Over levels: the quantifier is the caller's choice

`tag-list` is a *list* of tag-sets (one per path level). The `tag` operand decides a single set; how that lifts over the levels differs by what you are asking, and **the operand stays uniform** — the level-quantifier lives in the caller, not in branches inside the predicate.

**Membership — [filter-by-tag](../src/vfs/dir/filter.nix)** matches the expr against the **merged** set (`sundry.attrs.merge.concat tag-list`, a lossless union of every level's tags):

```nix
filter-by-tag (e: e.tag { b = "1"; }) dir      # file kept iff the merged set matches
```

Merging makes the quantifier fall out right: a value match is **existential** over levels (the value appears at *some* level). Negation over the merged set is therefore **universal** — `!(tag { b = []; })` holds when `b` is on *no* level. Matching per level with `lib.any` instead would let that pass any file with even one level lacking `b` — the bug this design avoids.

`filter-by-tag` takes an `expr-fn` over [boolean.expr](../src/boolean/expr.nix) operands, so disjunction and negation are just `||` and `!`:

```nix
filter-by-tag (e: with e; tag { hosts = host.name; } || !(tag { hosts = []; })) dir   # this host OR untagged
```

**Position — [get-tag-pos.nix](../src/vfs/file/get-tag-pos.nix)** is `findFirst` per level: it returns the index of the **first level** whose tag-set matches the expr, or `-1`. It is positional, so its match is per-level by definition.

## Worked example

File `tag-list = [ { a = "1"; } { b = ["1" "2"]; } ]`, merged `{ a = "1"; b = ["1" "2"]; }`:

| query | result |
|---|---|
| `filter-by-tag (e: e.tag { b = "2"; })` | kept — `b` present, `["1" "2"] ∩ ["2"] ≠ ∅` |
| `filter-by-tag (e: !(e.tag { a = []; }))` | dropped — `a` present in the merged set (universal absence) |
| `filter-by-tag (e: !(e.tag { c = []; }))` | kept — `c` on no level |
| `filter-by-tag (e: with e; tag { a = "9"; } || !(tag { c = []; }))` | kept — the second term holds (disjunction) |
| `get-tag-pos (e: e.tag { b = "1"; })` | `1` — first level with a matching `b` |
