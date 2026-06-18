{
  mlem,
  flake-root,
  ...
}: rec {
  from-src = vfs-path: fs-path:
    mlem.vfs.file.from-text vfs-path (builtins.readFile fs-path);
  tests = [
    [
      (from-src ["abc" "def" "A.txt"] "${flake-root}/tests/vfs-test-dir/test-files/A.txt")
      {
        abc = {
          def = {
            "A.txt" = {
              text = "contents of A.txt";
            };
          };
        };
      }
    ]
  ];
}
