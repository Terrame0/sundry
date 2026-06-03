{
  mlem,
  flake-root,
  ...
}: rec {
  from-real = vfs-path: fs-path:
    mlem.vfs.file.from-content vfs-path (builtins.readFile fs-path);
  tests = [
    [
      (from-real ["abc" "def" "a.txt"] "${flake-root}/tests/vfs-test-dir/test-files/a.txt")
      {
        abc = {
          def = {
            "a.txt" = {
              contents = "contents of a.txt";
            };
          };
        };
      }
    ]
  ];
}
