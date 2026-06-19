{
  sundry,
  flake-root,
  lib,
  ...
}: {
  reform =
    sundry.attrs.reform-until
    sundry.vfs.is-leaf-node;

  tests = let
    test-dir = sundry.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
  in [
    [
      (sundry.vfs.dir.reform (path: file: {
          path = [(lib.last path)];
          value = {
            path = sundry.vfs.path.get.str path;
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
