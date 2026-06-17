{
  lib,
  mlem,
  flake-root,
  ...
}: let
  get-spec-pos = spec: file:
    (mlem.for
      [
        (lib.length file.specs - 1)
        (i: i - 1)
        (i: i >= -1)
      ]
      {pos = -1;}
      (_: i: {
        break = let
          comparison =
            mlem.attrs.compare spec
            (mlem.list.at i file.specs);
        in
          (lib.all lib.id
            (lib.mapAttrsToList
              (name: value:
                mlem.list.at 0 value
                == mlem.list.at 1 value
                || mlem.list.at 0 value == {})
              comparison.matched))
          && (comparison.extra == {});
        pos = i;
      })).pos;
in rec {
  reform-by-spec = spec: fn:
    mlem.vfs.dir.reform (path: file: let
      spec-pos = get-spec-pos spec file;
    in
      if spec-pos == -1
      then {
        omit = true;
        path = [];
        value = {};
      }
      else fn path spec-pos file);

  filter-by-spec = spec:
    reform-by-spec spec (path: spec-pos: value: {
      omit = spec-pos == -1;
      inherit path;
      inherit value;
    });

  collapse-by-spec = spec: fn: dir:
    lib.concatLists (mlem.vfs.dir.collapse (path: file: let
      spec-pos = get-spec-pos spec file;
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
      (reform-by-spec {y = "1";} (path: spec-pos: file: {
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
    [
      (mlem.vfs.dir.collapse (path: file: file.contents) (filter-by-spec {y = "1";} dir))
      ["contents of c" "contents of h" "contents of f" "contents of e"]
    ]
    [
      (collapse-by-spec {y = "1";} (path: spec-pos: file: spec-pos) dir)
      [0 0 1 1]
    ]
  ];
}
