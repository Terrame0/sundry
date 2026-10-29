{
  sundry,
  lib,
  pkgs,
  fixtures-dir,
  ...
}: rec {
  python = {
    pname,
    src,
    version ? "1.0.0",
    entrypoint ? "main.py",
    entrypoint-fn ? "main",
    deps ? py: [],
  }: let
    target = lib.pipe entrypoint [
      sundry.vfs.path.from-str
      (sundry.vfs.path.set.ext "")
      (sundry.str.join-with ".")
    ];
    dependencies = deps pkgs.python3Packages;
    project-config =
      sundry.vfs.file.from-text ["pyproject.toml"]
      # -- 'only-include' disables hatchling's
      # - '<pname>/__init__.py' heuristic and
      # - packages the source tree as-is
      # -< toml >-
      ''
        [build-system]
        requires = ["hatchling"]
        build-backend = "hatchling.build"
        [project]
        name = "${pname}"
        version = "${version}"
        [project.scripts]
        ${pname} = "${target}:${entrypoint-fn}"
        [tool.hatch.build.targets.wheel]
        only-include = ["."]
      '';
    build-tree = lib.pipe src [
      sundry.vfs.tree.from-src
      (sundry.vfs.tree.merge project-config)
      (sundry.vfs.tree.materialize pname)
    ];
  in
    pkgs.python3Packages.buildPythonApplication {
      inherit dependencies pname version;
      allowSubstitutes = false;
      pyproject = true;
      src = build-tree.drv;
      build-system = [pkgs.python3Packages.hatchling];
    };

  tests = {
    build-hello = [
      (builtins.readFile (pkgs.runCommandLocal "python-test" {
        nativeBuildInputs = [
          (python {
            pname = "hello";
            src = fixtures-dir + "/python";
            entrypoint = "src/main.py";
            deps = py: [py.click];
          })
        ];
      } "hello 'world' > $out"))
      "hello, world!\n"
    ];
  };
}
