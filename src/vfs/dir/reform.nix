{
  mlem,
  flake-root,
  ...
}: rec {
  reform = mlem.attrs.reform-until (path: mlem.vfs.is-leaf);
  tests = [
    [
      (reform (path: file: {
        inherit path;
        value = file // {path = mlem.vfs.path.get.str path;};
      }) (mlem.vfs.dir.from-real "${flake-root}/tests/vfs-test-dir/test-files"))
      {
        "a.txt" = {
          contents = "contents of a.txt";
          path = "a.txt";
        };
        "b.txt" = {
          contents = "contents of b.txt";
          path = "b.txt";
        };
        nested = {
          "c.txt" = {
            contents = "contents of c.txt";
            path = "nested/c.txt";
          };
        };
      }
    ]
  ];
}
