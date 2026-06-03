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
      (path-strs (mlem.vfs.dir.from-real "${flake-root}/tests/vfs-test-dir/test-files"))
      [
        "test-files/a.txt"
        "test-files/b.txt"
        "test-files/nested/c.txt"
      ]
    ]
  ];
}
