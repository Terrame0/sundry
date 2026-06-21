# Tag matching

How a **tag-spec** queries a file's tags. The tag shape itself — `tag-list`, a per-path-level list of tag attrsets — lives in [data-model.md](data-model.md); this doc is the query semantics over it.

## A spec matches one tag-set: presence and value

[matches.nix](../src/vfs/tag/matches.nix) takes a `tag-spec` and a single `tag-set` (one `{ key = value; }` attrset) and returns a bool. A key's entry sits on two orthogonal axes — **presence** (is the key there at all) and **value** (which values it carries):

| spec entry | the tag-set passes when |
|---|---|
| `key = "1"` or `key = ["1" "2"]` | `key` present **and** values intersect (`∩ ≠ ∅`) |
| `key = (exclude "1")` | `key` present **and** values avoid it (`∩ = ∅`) |
| `key = [ "1" (exclude "3") ]` | `key` present, has an include term **and** avoids every exclude term |
| `key = []` | `key` present, any value (wildcard) |
| `key = null` | `key` absent |

Keys combine with **AND** across the spec. Within one key the value list is split by term: **include** terms combine with **OR** (hit at least one), **exclude** terms are each forbidden. Presence is the other axis, decided by `null` vs. non-`null` — any value list, even all-`exclude`, still requires the key present; `exclude` only constrains values, never presence. This is faceted-filter semantics: AND across facets, include/exclude within a facet.

[`exclude`](../src/vfs/tag/exclude.nix) wraps a value as a negative term (`sundry.vfs.tag.{exclude, is-excluded, unwrap-excluded}`). Include matching is set **intersection** ([list.intersect](../src/list/intersect.nix)), not subset: a file tag `hosts = ["desktop" "laptop"]` matches `hosts = "desktop"` because they overlap. Include terms are *additive* (more file values never drop a match); `exclude` is the one term that isn't — it lets you forbid a value, at the cost of that additivity.

## Over levels: the quantifier is the caller's choice

`tag-list` is a *list* of tag-sets (one per path level). `matches` decides a single set; how that lifts over the levels differs by what you are asking, and **`matches` stays uniform** — the level-quantifier lives in the caller, not in branches inside the predicate.

**Membership — [filter-by-tag.nix](../src/vfs/dir/filter-by-tag.nix)** matches the spec against the **merged** set (`sundry.attrs.merge.concat tag-list`, a lossless union of every level's tags):

```nix
filter-by-tag { b = "1"; } dir      # file kept iff the merged set matches
```

Merging makes the quantifiers fall out right: an include match is **existential** over levels (the value appears at *some* level), while `null`-absence and `exclude` are **universal** (the key is on *no* level / the value is on *no* level). Matching per level with `lib.any` instead would let `{ b = null; }` pass any file with even one level lacking `b` — the bug this design avoids.

`filter-by-tag` also takes a **list of specs** (disjunction at the argument level): the file is kept if it matches **any** spec.

```nix
filter-by-tag [ { hosts = host.name; } { hosts = null; } ] dir   # this host OR untagged
```

**Position — [get-tag-pos.nix](../src/vfs/file/get-tag-pos.nix)** is `findFirst` per level: it returns the index of the **first level** whose tag-set matches the spec, or `-1`. It is positional, so its match is per-level by definition — `{ a = null; }` finds the first level lacking `a`.

## Worked example

File `tag-list = [ { a = "1"; } { b = ["1" "2"]; } ]`, merged `{ a = "1"; b = ["1" "2"]; }`:

| query | result |
|---|---|
| `filter-by-tag { b = "2"; }` | kept — `b` present, `["1" "2"] ∩ ["2"] ≠ ∅` |
| `filter-by-tag { a = null; }` | dropped — `a` present in the merged set (universal absence) |
| `filter-by-tag { c = null; }` | kept — `c` on no level |
| `filter-by-tag { b = (exclude "3"); }` | kept — `b` present, lacks `3` |
| `filter-by-tag { b = (exclude "1"); }` | dropped — `b` carries `1` (excluded) |
| `filter-by-tag { b = [ "2" (exclude "1") ]; }` | dropped — has `2` but also `1` (excluded) |
| `filter-by-tag [ { a = "9"; } { c = null; } ]` | kept — the second spec holds (disjunction) |
| `get-tag-pos { b = "1"; }` | `1` — first level with a matching `b` |
| `get-tag-pos { a = null; }` | `1` — first level lacking `a` |
