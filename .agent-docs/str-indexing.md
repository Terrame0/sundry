# String indexing

How [`at`](../src/str/at.nix), [`slice`](../src/str/slice.nix), and [`range`](../src/range.nix) fit together to index and cut strings.

## `slice` is a composition, not a special case

`slice args-list str` folds [`at`](../src/str/at.nix) over the labels produced by [`range`](../src/range.nix):

```nix
slice = args-list: str:
  lib.foldl (acc: i: acc + sundry.str.at i str) "" (sundry.range args-list);
```

Neither primitive knows about slicing. `range` turns `[start stop step]` into integer labels, `at` maps one label to one character, `slice` concatenates. Reversal, stride, and "from the end" are consequences of those two, not branches in `slice`.

The same `range` is a general primitive — [permutations](../src/list/permutations.nix), [get-tag-pos](../src/vfs/file/get-tag-pos.nix), and [merge-fns](../src/attrs/merge-fns.nix) build index sequences with it too.

## A negative label is a position, not a normalized index

`at` accepts `0..len-1` and `-len..-1`, mapping a negative label `i` to cell `len+i`. A label stays signed through the `range` walk and is resolved to a cell only in `at`. Each cell therefore has **two labels**: `k` and `k-len`.

The count `range` walks is away-from-zero division of `stop-start` by `step` ([`div-away`](../src/math/div.nix)). When `stop` and `step` point opposite ways the count is negative and `range` clamps it with `lib.max 0`, so the slice is empty rather than an error — `slice [0 3 (-1)] "abc"` is `""`. A label outside `-len..len-1` is a catchable `throw` from `at`; there is no modular wrap, so a walk that runs past either end fails loudly.

## Divergence from Python

Positive stops behave exactly like Python. Divergence appears only at a **negative stop with a negative step** — Python normalizes the stop to `len+stop` before comparing, which collapses the walk; here the label stays negative.

For `"abcdefgh"` (length 8):

| Python | sundry | result |
|---|---|---|
| `s[5:1:-1]` | `slice [5 1 (-1)] s` | `"fedc"` — same |
| `s[5:0:-1]` | `slice [5 0 (-1)] s` | `"fedcb"` — same |
| `s[5:-1:-1]` | `slice [5 (-1) (-1)] s` | Python `""`, sundry `"fedcba"` |

The negative stop is what makes a full reverse expressible as `[<last> (-1) (-1)]` instead of a special `reverse` function. Mixed signed walks follow: `slice [1 (-2) (-1)] "abc"` is `"bac"` (labels `1, 0, -1`), and `slice [2 (-1) (-1)] "abc"` is `"cba"`.
