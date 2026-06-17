{
  mlem,
  flake-root,
  ...
}: rec {
  from-src = vfs-path: fs-path:
    mlem.vfs.file.from-contents vfs-path (builtins.readFile fs-path);
  tests = [
    [
      (from-src ["abc" "def" "A.txt"] "${flake-root}/tests/vfs-test-dir/test-files/A.txt")
      {
        abc = {
          def = {
            "A.txt" = {
              contents = "contents of A.txt";
            };
          };
        };
      }
    ]
  ];
}
