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
      separators = value: {
        default = ["{" ":" "," "}"];
        check =
          lib.isList value
          && lib.length value == 4
          && (lib.all lib.isString value);
        error-msg = "must be a list of the following format: [ left-sep key-value-sep value-sep right-sep ]";
      };
    };
    lsep = mlem.list.at 0 args.separators;
    kvsep = mlem.list.at 1 args.separators;
    vsep = mlem.list.at 2 args.separators;
    rsep = mlem.list.at 3 args.separators;
  in
    mlem.attrs.reform-until
    (path: mlem.vfs.is-leaf)
    (path: value: {
      path =
        if args.strip
        then map (path: "${lib.concatStrings (mlem.string.outside lsep rsep path)}") path
        else path;
      value =
        value
        // {
          specs = lib.pipe path [
            (map (dir:
              lib.pipe dir [
                (mlem.string.between lsep rsep)
                (map (spec-str: let
                  spec-parts = lib.splitString kvsep spec-str;
                  spec-key = lib.head spec-parts;
                  spec-value = mlem.list.excl-last spec-parts;
                  spec-values = mlem.not-null spec-value (lib.splitString vsep spec-value);
                in {
                  ${spec-key} =
                    mlem.not-null spec-values
                    (
                      if lib.length spec-values == 1
                      then mlem.list.at 0 spec-values
                      else spec-values
                    );
                }))
                mlem.attrs.merge.recursive.no-conflict
              ]))
            mlem.attrs.merge.recursive.no-collision
          ];
        };
    });
  tests = [
    [
      (resolve-specs {
          strip = true;
          separators = ["{" ":" "," "}"];
        }
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
            y = [
              "2"
              "3"
            ];
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
              y = [
                "2"
                "3"
              ];
            };
          };
        };
      }
    ]
  ];
}
