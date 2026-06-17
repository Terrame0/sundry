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
        "a.txt" = {
          contents = "reformed contents of a.txt";
          path = "a.txt";
        };
        "b.txt" = {
          contents = "reformed contents of b.txt";
          path = "b.txt";
        };
        "c.txt" = {
          contents = "reformed contents of c.txt";
          path = "nested/c.txt";
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
        "a.txt"
        "b.txt"
        "nested/c.txt"
        "nested/nested/e.ini"
        "nested/nested/g.txt"
      ]
    ]
    [
      (collapse (path: file: file.contents) test-dir)
      ["contents of a.txt" "contents of b.txt" "contents of c.txt"]
    ]
  ];
}
