# Python script wrapper

How [`sundry.script.python`](../src/script/python.nix) turns a VFS source tree into a Python application built with hatchling.

## The source root is the wheel root

Rule: a file at `<source>/<path>` ends up at `<site-packages>/<path>`. The tree is shipped verbatim, with no prefix stripped.

Why: the generated `pyproject.toml` sets `only-include = ["."]` and never sets `sources`. `only-include` turns off hatchling's default heuristic, which looks for `<pname>/__init__.py`, `src/<pname>/__init__.py`, or `<pname>.py` and aborts when none exists. That heuristic is unusable here because `pname` names a distribution and entry point, not a package directory. `sources` is the only option that strips a prefix.

The consequence matters for imports. A module's importable name is its path relative to the wheel root:

| `source` contains | Importable as |
|---|---|
| `main.py`, `hello.py` | `main`, `hello` |
| `src/main.py`, `src/hello.py` | `src.main`, `src.hello` |

A directory without `__init__.py`, such as `src/`, is still importable as a namespace package, but its children are not top-level modules.

## `entrypoint` is a path under `source`

`entrypoint` is resolved relative to `source` and converted to a dotted module path: `src/main.py` becomes `src.main` (`sundry.vfs.path.set.ext ""` followed by `sundry.str.join-with "."`). It goes into `[project.scripts]` as `<pname> = "<module>:<entrypoint-fn>"`.

The entry point does not affect file layout. Whatever layout the tree has, the entry module's own imports resolve from the wheel root, so a sibling of `src/main.py` must be imported as `from . import hello` or `import src.hello`, not `import hello`.

## Layouts

| `source` | `entrypoint` | Local import | Works |
|---|---|---|---|
| `main.py`, `hello.py` | `main.py` | `import hello` | yes |
| `src/main.py`, `src/hello.py` | `src/main.py` | `import src.hello` | yes |
| `src/main.py`, `src/hello.py` | `src/main.py` | `import hello` | no — no top-level `hello` |
| `src/main.py`, `src/hello.py` | `main.py` | `import hello` | no — `main.py` is not at the root |

A `src`-directory layout with top-level imports requires collapsing the prefix, which the wrapper does not do. Add `sources = ["src"]` under `[tool.hatch.build.targets.wheel]` in the project config and set `entrypoint` relative to `src` (`main.py`). Then `src/hello.py` is importable as `hello`.

## Dependencies

Two axes, with different mechanisms:

| argument | what it is | how it reaches the program |
|---|---|---|
| `python-deps` | Python packages the code imports | applied to `pkgs.python3Packages`, passed as `dependencies`, which nixpkgs propagates and the `wrapPython` hook turns into `site.addsitedir` entries inside `bin/.<pname>-wrapped` |
| `runtime-deps` | executables the code runs, e.g. `cowsay` | `makeWrapperArgs = ["--prefix" "PATH" ":" (lib.makeBinPath runtime-deps)]`, which prefixes the wrapper's `PATH` |

Write `python-deps = py: [py.click]`, not `python-deps = ["click"]`. `runtime-deps` takes plain packages: `runtime-deps = [pkgs.cowsay]`.

`python-deps` needs no `PATH` work — an import is resolved through the `site` path baked into the wrapper, so it works even under `env -i`. A binary is different: without `runtime-deps` the program only finds what the calling environment happens to have on `PATH`, which makes the package non-hermetic. Both behaviours are locked by tests that run under `env -i`.
