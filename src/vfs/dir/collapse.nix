{
  sundry,
  fixtures-dir,
  ...
}: {
  collapse =
    sundry.attrs.collapse-until
    sundry.vfs.node.halt;

  tests = let
    fixture-file-tree = sundry.vfs.dir.from-src (fixtures-dir + "/vfs-test-dir/test-files");
  in {
    collapsed-texts = [
      (sundry.vfs.dir.collapse (path: node: node.text) fixture-file-tree)
      ["contents of C.txt" "contents of A.txt" "contents of B.txt"]
    ];
  };
}
