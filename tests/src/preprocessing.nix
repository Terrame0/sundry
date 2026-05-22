{
  utils,
  flake-root,
  ...
}: [
  #[
  #  (utils.attrs.topo-merge [
  #    {
  #      name = "import-stage";
  #      attrs = prev:
  #        utils.dir.from-real
  #        "${flake-root}/tests/vfs-test-dir/preprocessing";
  #    }
  #    {
  #      name = "spec-resolution-stage";
  #      depends-on = ["import-stage"];
  #      attrs = prev: utils.dir.apply-to-files (path: file: {whatever = path;}) prev;
  #    }
  #  ])
  #]
]
