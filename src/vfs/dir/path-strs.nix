{
  mlem,
  flake-root,
  ...
}: rec {
  path-strs = dir:
    mlem.attrs.collapse-until
    mlem.vfs.is-leaf-node
    (path: _: mlem.vfs.path.get.str path)
    dir;
  tests = [
    [
      (path-strs (mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files"))
      [
        "=/C.txt"
        "A.txt"
        "B.txt"
      ]
    ]
  ];
}
