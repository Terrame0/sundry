{
  lib,
  utils,
  flake-root,
  ...
}: rec {
  apply-to-files = fn: dir:
    lib.mapAttrsRecursiveCond
    (attrs: !(attrs ? contents && lib.isString attrs.contents))
    (path: file: fn path file)
    dir;
  tests = [
    [
      (apply-to-files
        (path: attrs: {contents = "modified ${attrs.contents}";})
        (utils.dir.from-real "${flake-root}/tests/vfs-test-dir/test-files"))
      {
        test-files = {
          "a.txt" = {
            contents = "modified contents of a.txt";
          };
          "b.txt" = {
            contents = "modified contents of b.txt";
          };
          nested-dir = {
            "c.txt" = {
              contents = "modified contents of c.txt";
            };
          };
        };
      }
    ]
  ];
}
