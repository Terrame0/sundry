{
  sundry,
  lib,
  flake-root,
  ...
}: rec {
  from-src = dir-path: let
    path-to-file = fs-path:
      sundry.vfs.file.from-src
      (lib.drop
        (lib.length (sundry.vfs.path.from-str dir-path))
        (sundry.vfs.path.from-str fs-path))
      fs-path;
  in
    sundry.attrs.merge.recursive.no-collision
    (map path-to-file (lib.filesystem.listFilesRecursive dir-path));
  tests = [
    [
      (from-src "${flake-root}/tests/vfs-test-dir/test-files")
      {
        "A.txt" = {
          text = "contents of A.txt";
          origin = "${flake-root}/tests/vfs-test-dir/test-files/A.txt";
        };
        "B.txt" = {
          text = "contents of B.txt";
          origin = "${flake-root}/tests/vfs-test-dir/test-files/B.txt";
        };
        "=" = {
          "C.txt" = {
            text = "contents of C.txt";
            origin = "${flake-root}/tests/vfs-test-dir/test-files/=/C.txt";
          };
        };
      }
    ]
  ];
}
