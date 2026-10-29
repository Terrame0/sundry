{
  sundry,
  fixtures-dir,
  ...
}: {
  collapse =
    sundry.attrs.collapse-until
    sundry.vfs.node.halt;

  tests = let
    fixture-tree = sundry.vfs.tree.from-src (fixtures-dir + "/vfs-test-dir/test-files");
  in {
    collapsed-texts = [
      (sundry.vfs.tree.collapse (path: node: sundry.vfs.file.read node) fixture-tree)
      ["contents of C.txt" "contents of A.txt" "contents of B.txt"]
    ];
    malformed-leaf = [
      (sundry.does-throw
        (sundry.vfs.tree.collapse (path: node: node) {A = {junk = "abc";};}))
      true
    ];
  };
}
