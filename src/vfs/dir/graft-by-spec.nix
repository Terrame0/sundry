{
  lib,
  mlem,
  flake-root,
  ...
}: rec {
  graft-by-spec = spec:
    mlem.vfs.dir.reform (
      path: file: let
        res =
          mlem.while
          (state:
            (lib.length state.path != 0)
            && (lib.head state.specs != spec))
          {
            inherit path;
            inherit (file) specs;
          } (prev: {
            path = lib.drop 1 prev.path;
            specs = lib.drop 1 prev.specs;
          });
      in {
        path = res.path;
        value = file;
        omit = res.path == [];
      }
    );
  tests = [
    [
      (lib.pipe "${flake-root}/tests/vfs-test-dir/specs" [
        mlem.vfs.dir.from-real
        (mlem.vfs.dir.resolve-specs {strip = true;})
        (graft-by-spec {
          y = "1";
        })
      ])
      {
        nested = {
          f = {
            contents = "";
            specs = [{x = "1";} {y = "1";} {y = "2";}];
          };
          g = {
            contents = "";
            specs = [{y = "1";} {z = "2";}];
          };
        };
      }
    ]
  ];
}
