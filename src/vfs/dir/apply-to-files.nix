{
  lib,
  mlem,
  flake-root,
  ...
}: rec {
  apply-to-files = fn: dir:
    lib.mapAttrsRecursiveCond
    mlem.vfs.is-not-leaf
    (path: file: fn path file)
    dir;
  tests = [
    [
      (apply-to-files
        (path: attrs: {contents = "modified ${attrs.contents}";})
        (mlem.vfs.dir.from-real "${flake-root}/tests/vfs-test-dir/test-files"))
      {
        "a.txt" = {
          contents = "modified contents of a.txt";
        };
        "b.txt" = {
          contents = "modified contents of b.txt";
        };
        nested = {
          "c.txt" = {
            contents = "modified contents of c.txt";
          };
        };
      }
    ]
  ];
}
