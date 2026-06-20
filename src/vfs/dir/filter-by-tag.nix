{
  lib,
  sundry,
  flake-root,
  ...
}: {
  filter-by-tag = tag:
    sundry.vfs.dir.filter (path: file:
      sundry.vfs.file.get-tag-pos tag file != -1);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      sundry.vfs.dir.from-src
      (sundry.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (sundry.vfs.dir.collapse (path: file: file.text) (sundry.vfs.dir.filter-by-tag {b = "1";} dir))
      ["contents of H" "contents of G" "contents of I" "contents of C"]
    ]
  ];
}
