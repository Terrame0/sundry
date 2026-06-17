{
  mlem,
  flake-root,
  ...
}: {
  walk =
    mlem.attrs.walk-until
    mlem.vfs.is-leaf;

  tests = let
    test-dir = mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
  in [
    [
      (mlem.vfs.dir.walk (path: file: {contents = "walked ${file.contents}";}) test-dir)
      {
        "A.txt" = {contents = "walked contents of A.txt";};
        "B.txt" = {contents = "walked contents of B.txt";};
        "=" = {"C.txt" = {contents = "walked contents of C.txt";};};
      }
    ]
  ];
}
