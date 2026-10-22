# Testing

How tests are written and run in this library.

## Test format

Each `.nix` file under `src/` may export a `tests` attribute: a named attrset whose values are two-element lists.

```nix
tests = {
  <name> = [ <actual-expression> <expected-value> ];
  ...
};
```

The name is a short kebab-case description of the case (`empty-input`, `throws-on-empty`, `finds-at-end`) and is what the failure report prints. It must be a valid unquoted Nix identifier — start with a letter, then letters, digits, `-` or `'` — and unique within the file. Attrsets iterate lexicographically, not in source order, so do not rely on declaration order to group related cases; the name carries that meaning.

Tests are collected by [tests.nix](../tests.nix), which imports every module through [assemble.nix](../assemble.nix). The assembly strips `tests` from the module's public exports, so it never leaks into the `sundry.*` namespace.

Every entry must be a two-element list. `tests.nix` compares `actual` with `expected` and throws on a malformed entry, so a one-element list is a hard error rather than a debug print.

## Where tests live

Inline `tests = { ... }` blocks in the source file are the default. Use them whenever the test fixture is small and self-contained (an inline attrset, a string literal, a small list).

On-disk fixtures live under `test-fixtures/`, outside `src/` so the library globber never picks them up. Test modules address them through the `fixtures-dir` argument (`flake-dir + "/test-fixtures"`), so a fixture at `test-fixtures/vfs-test-dir/test-files` is `fixtures-dir + "/vfs-test-dir/test-files"`; never build the path from `flake-dir` or the module's own location. The VFS suite uses [test-fixtures/vfs-test-dir/](../test-fixtures/vfs-test-dir/) through `sundry.vfs.dir.from-src`; the Python packaging test uses [test-fixtures/python/](../test-fixtures/python/) as its source tree. The VFS fixture naming scheme is described in [test-naming.md](test-naming.md).

## Running tests

```bash
nu ./eval-tests.nu
```

`eval-tests.nu` evaluates `tests.nix` and renders the failures as a Nushell table: one row per failing case with `name`, `source`, `value`, and `expected`. `source` is relative to the repository root; `value` and `expected` are pretty-printed on one line. An empty result (Nushell renders it as `empty list`) means every check passed.

`tests.nix` is also the flake's `tests` output; it is a function taking `{lib, pkgs}`.

## Edge case coverage

The expected coverage per function:

1. **Happy path** — the function applied to a representative input.
2. **Obvious edges** — empty input, identity/no-op, boundary values, formal errors (when catchable). Only add what's *obviously* missing; do not invent exotica.
3. **Documented failure modes** — when a function throws on misuse and the throw is catchable, add a [`sundry.does-throw`](../src/does-throw.nix) test — `[(sundry.does-throw <expr>) true]` — to lock the contract in.

What does *not* warrant a test: alternative spellings of the happy path that don't exercise a new branch; property-based variants beyond what the implementation actually branches on.

## `does-throw` forces deeply, `does-throw-whnf` only to WHNF

[`sundry.does-throw`](../src/does-throw.nix) forces its argument with `builtins.deepSeq`, so an explicit `throw` anywhere inside it — including a lazy attrset field or list element — is caught. [`sundry.does-throw-whnf`](../src/does-throw.nix) forces only with `builtins.seq`: it catches a throw in the outer shell but is blind to one nested inside an attrset or list.

Use `does-throw-whnf` when the contract under test is about **not forcing payload**. A test like `[(does-throw-whnf (from-src ["A"] (throw "text was forced"))) false]` asserts that building the tree does not evaluate its `text`, which `does-throw` cannot express because it would force the throw.

The trick is to hand the variant the **exact level** being tested. `[(does-throw-whnf (load-nix dir)) false]` checks only that building the loaded tree does not import; `[(does-throw ((load-nix dir)."D-throws.nix".expr)) true]` selects the stored field so the import is actually reached. Pair every negative with such a positive control on the same payload, so the test cannot pass vacuously when the throw is unreachable.

Laziness contracts locked this way include the deferred read in [from-text](../src/vfs/file/from-text.nix) / [from-src](../src/vfs/file/from-src.nix), the deferred `import` in [load-nix](../src/vfs/dir/load-nix.nix), unforced sibling transforms in [resolve-deps](../src/attrs/resolve-deps.nix), defaults that run only for absent fields and `nullable` nulls that bypass `check` in [validate](../src/attrs/validate.nix), the unbuilt derivation behind the [materialize](../src/vfs/dir/materialize.nix) result, and the collision in [resolve-tags](../src/vfs/dir/resolve-tags.nix) that surfaces only when the rebuilt fields are demanded.

Reserve these tests for contracts that are both documented and fragile — where a refactor could plausibly force payload that should stay lazy. Branch-laziness inherited from a primitive such as `lib.mapAttrs`, as in [walk](../src/attrs/walk.nix), is the library's own behavior and does not earn a test.

## `does-throw` does not catch everything

[`sundry.does-throw`](../src/does-throw.nix) deeply evaluates its argument with `builtins.deepSeq` before inspecting `builtins.tryEval`. Explicit errors inside lazy attrset fields or list elements are therefore observable without selecting each nested value in the test expression.

In the project's current Nix evaluator, `builtins.tryEval` turns an explicit `throw` or a failed `assert` into `success = false`. It does **not** catch `abort` or evaluator errors raised by built-ins, such as:

- `builtins.head []`, `builtins.tail []`, `builtins.elemAt list i` out of range
- `attrs.${missing-key}`, `lib.getAttrFromPath` on a non-existent path
- type mismatches at the C-implementation level

If a function's edge case hits one of those (e.g. `excl-head []` calls `lib.head []` internally), the case **cannot** be expressed as a test — `does-throw` re-throws an uncatchable error and the whole suite blows up. Either rewrite the function to `throw` explicitly on the bad input, or accept that the case is undefined behavior and leave it out.
