{
  lib,
  sundry,
  flake-root,
  ...
}: {
  collapse = tag: fn: dir:
    lib.concatLists (sundry.vfs.dir.collapse (path: file: let
      tag-pos = sundry.vfs.file.get-tag-pos tag file;
    in
      if tag-pos == -1
      then []
      else [(fn path tag-pos file)])
    dir);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      sundry.vfs.dir.from-src
      (sundry.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (sundry.vfs.dir.by-tag.collapse {b = "1";} (path: tag-pos: file: tag-pos) dir)
      [1 1 0 0]
    ]
  ];
}
