{
  sundry,
  lib,
  fixtures-dir,
  ...
}: rec {
  load-nix-with = fn:
    sundry.vfs.dir.walk
    (path: node: node // {expr = fn path node (import node.origin);});

  load-nix =
    load-nix-with
    (_: _: expr: expr);

  tests = let
    nix-file-tree = sundry.vfs.dir.from-src (fixtures-dir + "/vfs-test-dir/nix");
    loadable-file-tree =
      sundry.vfs.dir.filter
      (path: _: lib.last path != "D-throws.nix")
      nix-file-tree;
  in {
    loadable-paths = [
      (lib.pipe loadable-file-tree [
        (load-nix-with (path: _: expr: expr path))
        (sundry.vfs.dir.collapse (path: node: node.expr))
      ])
      [{a = ["A.nix"];} {b = ["B.nix"];} {c = ["C.txt"];}]
    ];
    lazy-load = [(sundry.does-throw-whnf (load-nix nix-file-tree)) false];
    throws-on-d-throws = [(sundry.does-throw ((load-nix nix-file-tree)."D-throws.nix".expr)) true];
  };
}
