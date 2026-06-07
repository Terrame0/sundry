{
  lib,
  mlem,
  flake-root,
  ...
}: [
  #[
  #  (mlem.attrs.topo-merge [
  #    {
  #      name = "import-stage";
  #      attrs = prev:
  #        mlem.vfs.dir.from-src
  #        "${flake-root}/tests/vfs-test-dir/preprocessing";
  #    }
  #    {
  #      name = "spec-resolution-stage";
  #      deps = ["import-stage"];
  #      attrs = prev:
  #        mlem.vfs.dir.resolve-specs prev;
  #    }
  #  ])
  #]
]
