{
  lib,
  mlem,
  flake-root,
  ...
}: rec {
  reform-by-spec = spec: fn:
    mlem.vfs.dir.reform (path: file: let
      result =
        mlem.for
        [
          (lib.length path - 1)
          (i: i - 1)
          (i: i >= -1)
        ]
        {id = -1;}
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
          id = i;
        });
    in
      if result.id == -1
      then {
        omit = true;
        path = [];
        value = {};
      }
      else fn path result.id file);

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
  ];
}
