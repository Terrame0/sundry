{
  lib,
  mlem,
  flake-root,
  ...
}: {
  collapse = tag: fn: dir:
    lib.concatLists (mlem.vfs.dir.collapse (path: file: let
      tag-pos = mlem.vfs.file.get-tag-pos tag file;
    in
      if tag-pos == -1
      then []
      else [(fn path tag-pos file)])
    dir);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.by-tag.collapse {b = "1";} (path: tag-pos: file: tag-pos) dir)
      [1 1 0 0]
    ]
  ];
}
