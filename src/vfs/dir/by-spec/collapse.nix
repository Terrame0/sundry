{
  lib,
  mlem,
  flake-root,
  ...
}: {
  collapse = spec: fn: dir:
    lib.concatLists (mlem.vfs.dir.collapse (path: file: let
      spec-pos = mlem.vfs.file.get-spec-pos spec file;
    in
      if spec-pos == -1
      then []
      else [(fn path spec-pos file)])
    dir);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/specs" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-specs {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.by-spec.collapse {y = "1";} (path: spec-pos: file: spec-pos) dir)
      [0 0 1 1]
    ]
  ];
}
