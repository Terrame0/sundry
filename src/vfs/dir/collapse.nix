{
  mlem,
  flake-root,
  lib,
  ...
}: rec {
  collapse = lib.mapAttrsToListRecursiveCond (path: mlem.vfs.is-not-leaf);
  tests = [
    [
      (collapse (path: file: {
        name = mlem.vfs.path.get.str path;
        value = file.contents;
      }) (mlem.vfs.dir.from-real "${flake-root}/tests/vfs-test-dir/test-files"))
      [
        {
          name = "a.txt";
          value = "contents of a.txt";
        }
        {
          name = "b.txt";
          value = "contents of b.txt";
        }
        {
          name = "nested/c.txt";
          value = "contents of c.txt";
        }
      ]
    ]
  ];
}
