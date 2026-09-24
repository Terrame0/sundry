{
  sundry,
  lib,
  flake-root,
  ...
}: rec {
  load-nix-with = fn:
    sundry.vfs.dir.walk
    (path: file: file // {expr = fn path file (import file.origin);});

  load-nix =
    load-nix-with
    (path: file: expr: expr);

  tests = let
    dir = sundry.vfs.dir.from-src (flake-root + "/tests/vfs-test-dir/nix");
    loadable =
      sundry.vfs.dir.filter
      (path: _: lib.last path != "D-throws.nix")
      dir;
  in [
    [
      (lib.pipe loadable [
        (load-nix-with (path: file: expr: expr path))
        (sundry.vfs.dir.collapse (path: file: file.expr))
      ])
      [{a = ["A.nix"];} {b = ["B.nix"];} {c = ["C.txt"];}]
    ]
    [(sundry.does-throw-whnf (load-nix dir)) false]
    [(sundry.does-throw ((load-nix dir)."D-throws.nix".expr)) true]
  ];
}
