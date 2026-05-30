{
  utils,
  lib,
  flake-root,
  ...
}: rec {
  from-real = dir-path: let
    path-to-file = fs-path:
      utils.file.from-real
      (lib.drop
        (lib.length (utils.path.to-attrs dir-path).path - 1)
        (utils.path.to-attrs fs-path).path)
      fs-path;
  in
    utils.attrs.merge.recursive.no-override
    (map path-to-file (lib.filesystem.listFilesRecursive dir-path));
  tests = [
    [
      (from-real "${flake-root}/tests/vfs-test-dir/test-files")
      {
        test-files = {
          "a.txt" = {
            contents = "contents of a.txt";
          };
          "b.txt" = {
            contents = "contents of b.txt";
          };
          nested-dir = {
            "c.txt" = {
              contents = "contents of c.txt";
            };
          };
        };
      }
    ]
  ];
}
