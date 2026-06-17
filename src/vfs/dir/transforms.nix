{
  mlem,
  flake-root,
  lib,
  ...
}: rec {
  reform =
    mlem.attrs.reform-until
    mlem.vfs.is-leaf;

  filter =
    mlem.attrs.filter-until
    mlem.vfs.is-leaf;

  collapse =
    mlem.attrs.collapse-until
    mlem.vfs.is-leaf;

  walk =
    mlem.attrs.walk-until
    mlem.vfs.is-leaf;

  tests = let
    test-dir = mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
    filter-dir = mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/filtering";
  in [
    [
      (reform (path: file: {
          path = [(lib.last path)];
          value = {
            path = mlem.vfs.path.get.str path;
            contents = "reformed ${file.contents}";
          };
        })
        test-dir)
      {
        "A.txt" = {
          contents = "reformed contents of A.txt";
          path = "A.txt";
        };
        "B.txt" = {
          contents = "reformed contents of B.txt";
          path = "B.txt";
        };
        "C.txt" = {
          contents = "reformed contents of C.txt";
          path = "=/C.txt";
        };
      }
    ]
    [
      (lib.pipe filter-dir [
        (mlem.vfs.dir.filter (path: file:
          mlem.vfs.path.get.ext path
          == "txt"
          || file.contents
          == "override"))
        mlem.vfs.dir.path-strs
      ])
      [
        "=/=/E.ini"
        "=/=/G.txt"
        "=/C.txt"
        "A.txt"
        "B.txt"
      ]
    ]
    [
      (collapse (path: file: file.contents) test-dir)
      ["contents of C.txt" "contents of A.txt" "contents of B.txt"]
    ]
    [
      (walk (path: file: {contents = "walked ${file.contents}";}) test-dir)
      {
        "A.txt" = {contents = "walked contents of A.txt";};
        "B.txt" = {contents = "walked contents of B.txt";};
        "=" = {"C.txt" = {contents = "walked contents of C.txt";};};
      }
    ]
  ];
}
