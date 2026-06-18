{
  mlem,
  flake-root,
  lib,
  ...
}: {
  reform =
    mlem.attrs.reform-until
    mlem.vfs.is-leaf;

  tests = let
    test-dir = mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
  in [
    [
      (mlem.vfs.dir.reform (path: file: {
          path = [(lib.last path)];
          value = {
            path = mlem.vfs.path.get.str path;
            text = "reformed ${file.text}";
          };
        })
        test-dir)
      {
        "A.txt" = {
          text = "reformed contents of A.txt";
          path = "A.txt";
        };
        "B.txt" = {
          text = "reformed contents of B.txt";
          path = "B.txt";
        };
        "C.txt" = {
          text = "reformed contents of C.txt";
          path = "=/C.txt";
        };
      }
    ]
  ];
}
