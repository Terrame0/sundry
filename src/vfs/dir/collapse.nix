{
  mlem,
  flake-root,
  ...
}: {
  collapse =
    mlem.attrs.collapse-until
    mlem.vfs.is-leaf-node;

  tests = let
    test-dir = mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
  in [
    [
      (mlem.vfs.dir.collapse (path: file: file.text) test-dir)
      ["contents of C.txt" "contents of A.txt" "contents of B.txt"]
    ]
  ];
}
