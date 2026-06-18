{
  lib,
  mlem,
  flake-root,
  ...
}: {
  filter = tag:
    mlem.vfs.dir.by-tag.reform tag (path: tag-pos: value: {
      omit = tag-pos == -1;
      inherit path;
      inherit value;
    });

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.collapse (path: file: file.text) (mlem.vfs.dir.by-tag.filter {b = "1";} dir))
      ["contents of H" "contents of G" "contents of I" "contents of C"]
    ]
  ];
}
