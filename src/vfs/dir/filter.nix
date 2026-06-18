{
  mlem,
  flake-root,
  lib,
  ...
}: {
  filter =
    mlem.attrs.filter-until
    mlem.vfs.is-leaf;

  tests = let
    filter-dir = mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/filtering";
  in [
    [
      (lib.pipe filter-dir [
        (mlem.vfs.dir.filter (path: file:
          mlem.vfs.path.get.ext path
          == "txt"
          || file.text
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
  ];
}
