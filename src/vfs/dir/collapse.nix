{
  sundry,
  flake-root,
  ...
}: {
  collapse =
    sundry.attrs.collapse-until
    sundry.vfs.is-leaf-node;

  tests = let
    test-dir = sundry.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
  in [
    [
      (sundry.vfs.dir.collapse (path: file: file.text) test-dir)
      ["contents of C.txt" "contents of A.txt" "contents of B.txt"]
    ]
  ];
}
