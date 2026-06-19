{
  sundry,
  flake-root,
  ...
}: {
  walk =
    sundry.attrs.walk-until
    sundry.vfs.is-leaf-node;

  tests = let
    test-dir = sundry.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
  in [
    [
      (sundry.vfs.dir.walk (path: file: {text = "walked ${file.text}";}) test-dir)
      {
        "A.txt" = {text = "walked contents of A.txt";};
        "B.txt" = {text = "walked contents of B.txt";};
        "=" = {"C.txt" = {text = "walked contents of C.txt";};};
      }
    ]
  ];
}
