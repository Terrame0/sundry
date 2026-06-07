{
  lib,
  mlem,
  flake-root,
  ...
}: rec {
  path-strs = dir:
    lib.mapAttrsToListRecursiveCond
    (path: mlem.vfs.is-not-leaf)
    (path: _: mlem.vfs.path.get.str path)
    dir;
  tests = [
    [
      (path-strs (mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files"))
      [
        "a.txt"
        "b.txt"
        "nested/c.txt"
      ]
    ]
  ];
}
