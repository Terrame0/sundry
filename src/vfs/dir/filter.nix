{
  sundry,
  flake-root,
  lib,
  ...
}: {
  filter =
    sundry.attrs.filter-until
    sundry.vfs.is-leaf-node;

  tests = let
    filter-dir = sundry.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/filtering";
  in [
    [
      (lib.pipe filter-dir [
        (sundry.vfs.dir.filter (path: file:
          sundry.vfs.path.get.ext path
          == "txt"
          || file.text
          == "override"))
        sundry.vfs.dir.path-strs
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
