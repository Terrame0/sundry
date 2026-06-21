{
  lib,
  sundry,
  flake-root,
  ...
}: {
  filter-by-tag = tag:
    sundry.vfs.dir.filter (path: file: let
      tags = sundry.attrs.merge.concat file.tag-list;
    in
      lib.any (spec: sundry.vfs.tags-match spec tags) (lib.toList tag));

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
    [
      (sundry.vfs.dir.collapse (path: file: file.text) (sundry.vfs.dir.filter-by-tag {b = null;} dir))
      ["contents of F" "contents of A" "contents of B" "contents of E"]
    ]
    [
      (sundry.vfs.dir.collapse (path: file: file.text) (sundry.vfs.dir.filter-by-tag [{b = "1";} {b = null;}] dir))
      ["contents of H" "contents of G" "contents of F" "contents of I" "contents of A" "contents of B" "contents of C" "contents of E"]
    ]
  ];
}
