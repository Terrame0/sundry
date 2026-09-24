# Testing

How tests are written and run in this library.

## Test format

Each `.nix` file under `src/` may export a `tests` attribute that is a list of two-element lists:

```nix
tests = [
  [ <actual-expression> <expected-value> ]
  ...
];
```

Tests are evaluated by [core/eval-tests.nix](../core/eval-tests.nix). The framework strips `tests` from the module's public exports, so it never leaks into the `sundry.*` namespace.

A single-element list `[ <value> ]` instead of `[ actual expected ]` is treated as a **debug print** — the value is rendered and shown regardless of correctness. Useful when probing behavior.

## Where tests live

Inline `tests = [...]` blocks in the source file are the default. Use them whenever the test fixture is small and self-contained (an inline attrset, a string literal, a small list).

On-disk fixtures live under `tests/`. The VFS suite uses [tests/vfs-test-dir/](../tests/vfs-test-dir/) through `sundry.vfs.dir.from-src`; the Python packaging test uses [tests/python/](../tests/python/) as its source tree. The VFS fixture naming scheme is described in [test-naming.md](test-naming.md).

## Running tests

```bash
bash eval-result.sh
```

Returns a Nix list containing failing check reports and every single-element debug report. Empty list `[ ]` means all checks pass and no debug entries remain.

Each failure is formatted as labeled `expected` and `got` blocks with the source file path.

## Edge case coverage

The expected coverage per function:

1. **Happy path** — the function applied to a representative input.
2. **Obvious edges** — empty input, identity/no-op, boundary values, formal errors (when catchable). Only add what's *obviously* missing; do not invent exotica.
3. **Documented failure modes** — when a function throws on misuse and the throw is catchable, add a [`sundry.does-throw`](../src/does-throw.nix) test — `[(sundry.does-throw <expr>) true]` — to lock the contract in.

What does *not* warrant a test: alternative spellings of the happy path that don't exercise a new branch; property-based variants beyond what the implementation actually branches on.

## `does-throw` forces deeply, `does-throw-whnf` only to WHNF

[`sundry.does-throw`](../src/does-throw.nix) forces its argument with `builtins.deepSeq`, so an explicit `throw` anywhere inside it — including a lazy attrset field or list element — is caught. [`sundry.does-throw-whnf`](../src/does-throw.nix) forces only with `builtins.seq`: it catches a throw in the outer shell but is blind to one nested inside an attrset or list.

Use `does-throw-whnf` when the contract under test is about **not forcing payload**. A test like `[(does-throw-whnf (from-src ["A"] (throw "text was forced"))) false]` asserts that building the tree does not evaluate its `text`, which `does-throw` cannot express because it would force the throw.

The trick is to hand the variant the **exact level** being tested. Selecting a branch first — `(does-throw-whnf (walk (_: _: null) {A = ...; B = throw "B was forced";}).A)` — checks that reading `A` never touches the throwing sibling; handing it the whole `walk` result would instead check only that the root shell builds. Pair such a negative with a `does-throw` positive control on the same payload (`...).B`) so the test cannot pass vacuously when the throw is unreachable.

Laziness contracts locked this way include the deferred read in [from-text](../src/vfs/file/from-text.nix) / [from-src](../src/vfs/file/from-src.nix), the deferred `import` in [load-nix](../src/vfs/dir/load-nix.nix), and unforced sibling transforms in [resolve-deps](../src/attrs/resolve-deps.nix).

Reserve these tests for contracts that are both documented and fragile — where a refactor could plausibly force payload that should stay lazy. Branch-laziness inherited from a primitive such as `lib.mapAttrs`, as in [walk](../src/attrs/walk.nix), is the library's own behavior and does not earn a test.

## `does-throw` does not catch everything

[`sundry.does-throw`](../src/does-throw.nix) deeply evaluates its argument with `builtins.deepSeq` before inspecting `builtins.tryEval`. Explicit errors inside lazy attrset fields or list elements are therefore observable without selecting each nested value in the test expression.

In the project's current Nix evaluator, `builtins.tryEval` turns an explicit `throw` or a failed `assert` into `success = false`. It does **not** catch `abort` or evaluator errors raised by built-ins, such as:

- `builtins.head []`, `builtins.tail []`, `builtins.elemAt list i` out of range
- `attrs.${missing-key}`, `lib.getAttrFromPath` on a non-existent path
- type mismatches at the C-implementation level

If a function's edge case hits one of those (e.g. `excl-head []` calls `lib.head []` internally), the case **cannot** be expressed as a test — `does-throw` re-throws an uncatchable error and the whole suite blows up. Either rewrite the function to `throw` explicitly on the bad input, or accept that the case is undefined behavior and leave it out.
