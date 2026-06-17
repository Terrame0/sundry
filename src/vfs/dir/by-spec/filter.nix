{
  lib,
  mlem,
  flake-root,
  ...
}: {
  filter = spec:
    mlem.vfs.dir.by-spec.reform spec (path: spec-pos: value: {
      omit = spec-pos == -1;
      inherit path;
      inherit value;
    });

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/specs" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-specs {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.collapse (path: file: file.contents) (mlem.vfs.dir.by-spec.filter {b = "1";} dir))
      ["contents of H" "contents of G" "contents of I" "contents of C"]
    ]
  ];
}
