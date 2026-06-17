# Test fixture naming convention

A three-layer character scheme used in `tests/vfs-test-dir/` so that file names, spec keys, and spec values are visually distinct at a glance. Use this convention for any new VFS test fixtures.

## Layers

| Layer | Symbols | Sequence | Purpose |
|---|---|---|---|
| File names | `A`, `B`, `C`, ... | uppercase, from start of alphabet, in order of appearance in the tree | distinct, easy to spot in path strings |
| Directory names | `=` | always `=` (nested: `=/=/=`) | makes the path skeleton visually obvious |
| Spec keys | `a`, `b`, `c`, ... | lowercase, from start of alphabet | separate namespace from file names |
| Spec values | `1`, `2`, `3`, ... | digits, from `1` | separate namespace from keys |

File extensions (`.txt`, `.ini`, `.scss`) are allowed when a test needs to distinguish them — see [tests/vfs-test-dir/filtering/](../tests/vfs-test-dir/filtering/) for an example where `.txt` vs `.ini` drives the filter predicate.

File contents are **out of scope** for this convention. They usually follow `contents of <NAME>` for readability, but tests that key off a specific content value (e.g. `override` in `=/=/E.ini`) deviate freely.

## Reference fixture

[tests/vfs-test-dir/specs/](../tests/vfs-test-dir/specs/) is the canonical example. Its layout:

```
A{a:1}
B{a:2,3}
C{a:1}{b:1}
D{a}{b:}
E
={a:1}/F{a:2}
={a:1}/={b:1}/G{b:2}
={a:1}/={b:1}/={c:1}/H{c:2}
={b:1}/I{c:1}
```

Reading any of these is mechanical: uppercase letter = file, `=` = directory step, lowercase-colon-digit = spec annotation.

## A note on sort order

`=` has ASCII codepoint 61; uppercase letters start at 65. Nix sorts attribute names lexicographically, so in a `collapse` traversal, `=`-prefixed (directory) entries are visited **before** any file at the same level. Tests that assert on traversal order need to account for this.
