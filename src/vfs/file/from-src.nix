{
  mlem,
  flake-root,
  ...
}: rec {
  from-src = vfs-path: fs-path:
    mlem.vfs.file.from-contents vfs-path (builtins.readFile fs-path);
  tests = [
    [
      (from-src ["abc" "def" "a.txt"] "${flake-root}/tests/vfs-test-dir/test-files/a.txt")
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
