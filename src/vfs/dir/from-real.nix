{
  mlem,
  lib,
  flake-root,
  ...
}: rec {
  from-real = dir-path: let
    path-to-file = fs-path:
      mlem.vfs.file.from-real
      (lib.drop
        (lib.length (mlem.vfs.path.from-str dir-path) - 1)
        (mlem.vfs.path.from-str fs-path))
      fs-path;
  in
    mlem.attrs.merge.recursive.no-collision
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
          nested = {
            "c.txt" = {
              contents = "contents of c.txt";
            };
          };
        };
      }
    ]
  ];
}
