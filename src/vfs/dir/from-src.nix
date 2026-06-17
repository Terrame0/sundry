{
  mlem,
  lib,
  flake-root,
  ...
}: rec {
  from-src = dir-path: let
    path-to-file = fs-path:
      mlem.vfs.file.from-src
      (lib.drop
        (lib.length (mlem.vfs.path.from-str dir-path))
        (mlem.vfs.path.from-str fs-path))
      fs-path;
  in
    mlem.attrs.merge.recursive.no-collision
    (map path-to-file (lib.filesystem.listFilesRecursive dir-path));
  tests = [
    [
      (from-src "${flake-root}/tests/vfs-test-dir/test-files")
      {
        "A.txt" = {
          contents = "contents of A.txt";
        };
        "B.txt" = {
          contents = "contents of B.txt";
        };
        "=" = {
          "C.txt" = {
            contents = "contents of C.txt";
          };
        };
      }
    ]
  ];
}
