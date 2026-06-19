{
  lib,
  sundry,
  flake-root,
  ...
}: {
  filter = tag:
    sundry.vfs.dir.by-tag.reform tag (path: tag-pos: value: {
      omit = tag-pos == -1;
      inherit path;
      inherit value;
    });

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      sundry.vfs.dir.from-src
      (sundry.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (sundry.vfs.dir.collapse (path: file: file.text) (sundry.vfs.dir.by-tag.filter {b = "1";} dir))
      ["contents of H" "contents of G" "contents of I" "contents of C"]
    ]
  ];
}
