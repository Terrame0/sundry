{
  sundry,
  lib,
  fixtures-dir,
  ...
}: rec {
  load-nix-with = fn:
    sundry.vfs.tree.walk
    (path: node: node // {expr = fn path node (import node.origin);});

  load-nix =
    load-nix-with
    (_: _: expr: expr);

  tests = let
    nix-tree = sundry.vfs.tree.from-src (fixtures-dir + "/vfs-test-dir/nix");
    loadable-tree =
      sundry.vfs.tree.filter
      (path: _: lib.last path != "D-throws.nix")
      nix-tree;
  in {
    loadable-paths = [
      (lib.pipe loadable-tree [
        (load-nix-with (path: _: expr: expr path))
        (sundry.vfs.tree.collapse (path: node: node.expr))
      ])
      [{a = ["A.nix"];} {b = ["B.nix"];} {c = ["C.txt"];}]
    ];
    lazy-load = [(sundry.does-throw-whnf (load-nix nix-tree)) false];
    throws-on-d-throws = [(sundry.does-throw ((load-nix nix-tree)."D-throws.nix".expr)) true];
  };
}
