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
            && !(
              let
                comparison = mlem.attrs.compare spec (lib.head state.specs);
                is-subset = comparison.extra == {};
                values-match = lib.pipe comparison.matched [
                  (lib.mapAttrsToList
                    (name: value:
                      mlem.list.at 0 value
                      == mlem.list.at 1 value))
                  (lib.all lib.id)
                ];
              in
                is-subset && values-match
            ))
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
  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/specs" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-specs {strip = true;})
    ];
  in [
    [
      (graft-by-spec {
          x = "1";
          y = "1";
        }
        dir)
    ]
    [
      (graft-by-spec {
          y = "1";
        }
        dir)
      {
        c = {
          contents = "";
          specs = [
            {
              x = "1";
              y = "1";
            }
          ];
        };
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
