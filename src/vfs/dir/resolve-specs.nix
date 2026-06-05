{
  lib,
  mlem,
  flake-root,
  ...
}: rec {
  resolve-specs = args-in: let
    args = mlem.attrs.validate args-in {
      strip = value: {
        default = false;
        check = lib.isBool value;
        error-msg = "must be either 'true' or 'false'";
      };
    };
  in
    mlem.attrs.reform-until
    (path: mlem.vfs.is-leaf)
    (path: value: {
      path =
        if args.strip
        then map (path: "${lib.concatStrings (mlem.string.outside "[" "]" path)}") path
        else path;
      value =
        value
        // {
          specs = mlem.attrs.merge.recursive.no-collision (map (dir:
            mlem.attrs.merge.recursive.no-conflict
            (map (spec-str: let
              spec-parts = lib.splitString ":" spec-str;
            in {${lib.head spec-parts} = mlem.list.excl-last spec-parts;})
            (mlem.string.between "[" "]" dir)))
          path);
        };
    });
  tests = [
    [
      (resolve-specs {strip = true;}
        (mlem.vfs.dir.from-real
          "${flake-root}/tests/vfs-test-dir/specs"))
      {
        "a.txt" = {
          contents = "";
          specs = {
            "1" = null;
            "2" = null;
          };
        };
        b = {
          contents = "";
          specs = {
            x = "1";
            y = "2";
          };
        };
        nested = {
          c = {
            contents = "";
            specs = {
              x = null;
              y = "1";
            };
          };
          d = {
            contents = "";
            specs = {
              x = null;
              y = "2";
            };
          };
        };
      }
    ]
  ];
}
