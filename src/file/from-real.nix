{
  utils,
  flake-root,
  ...
}: rec {
  from-real = vfs-path: fs-path:
    utils.file.from-content vfs-path (builtins.readFile fs-path);
  tests = [
    [
      (from-real ["abc" "def" "a-virtual.txt"] "${flake-root}/tests/vfs-test-dir/test-files/a.txt")
      {
        abc = {
          def = {
            "a-virtual.txt" = {
              contents = "contents of a.txt";
            };
          };
        };
      }
    ]
  ];
}
