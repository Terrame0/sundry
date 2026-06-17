{
  lib,
  mlem,
  flake-root,
  ...
}: {
  reform = spec: fn:
    mlem.vfs.dir.reform (path: file: let
      spec-pos = mlem.vfs.file.get-spec-pos spec file;
    in
      if spec-pos == -1
      then {
        omit = true;
        path = [];
        value = {};
      }
      else fn path spec-pos file);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/specs" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-specs {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.by-spec.reform {y = "1";} (path: spec-pos: file: {
          path = [(lib.last path)];
          value = spec-pos;
        })
        dir)
      {
        c = 0;
        e = 1;
        f = 1;
        h = 0;
      }
    ]
  ];
}
