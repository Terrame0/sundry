{
  lib,
  mlem,
  flake-root,
  ...
}: rec {
  resolve-specs = args-in: let
    args = mlem.attrs.validate args-in {
      strip = {
        default = false;
        check = value: lib.isBool value;
        desc = "must be either 'true' or 'false'";
      };
      separators = {
        default = ["{" ":" "," "}"];
        check = value:
          lib.isList value
          && lib.length value == 4
          && (lib.all lib.isString value);
        desc = "must be a list of the following format: [ left-sep key-value-sep value-sep right-sep ]";
      };
    };
    lsep = mlem.list.at 0 args.separators;
    kvsep = mlem.list.at 1 args.separators;
    vsep = mlem.list.at 2 args.separators;
    rsep = mlem.list.at 3 args.separators;
  in
    mlem.attrs.reform-until
    mlem.vfs.is-leaf
    (path: value: {
      path =
        if args.strip
        then mlem.vfs.path.strip-between lsep rsep path
        else path;
      value =
        value
        // {
          specs = map (dir:
            lib.pipe dir [
              (mlem.str.between lsep rsep)
              (map (spec-str: let
                spec-parts = lib.splitString kvsep spec-str;
                spec-key = lib.head spec-parts;
                spec-value = mlem.is-null (mlem.list.excl-last spec-parts) "";
                spec-list = lib.splitString vsep spec-value;
              in {
                ${spec-key} = mlem.list.un-singleton spec-list;
              }))
              mlem.attrs.merge.no-collision
            ])
          path;
        };
    });
  tests = [
    [
      (lib.pipe "${flake-root}/tests/vfs-test-dir/specs" [
        mlem.vfs.dir.from-src
        (resolve-specs {
          strip = true;
          separators = ["{" ":" "," "}"];
        })
      ])
      {
        A = {
          contents = "contents of A";
          specs = [{a = "1";}];
        };
        B = {
          contents = "contents of B";
          specs = [{a = ["2" "3"];}];
        };
        C = {
          contents = "contents of C";
          specs = [
            {
              a = "1";
              b = "1";
            }
          ];
        };
        D = {
          contents = "contents of D";
          specs = [
            {
              a = "";
              b = "";
            }
          ];
        };
        E = {
          contents = "contents of E";
          specs = [{}];
        };
        "=" = {
          F = {
            contents = "contents of F";
            specs = [{a = "1";} {a = "2";}];
          };
          I = {
            contents = "contents of I";
            specs = [{b = "1";} {c = "1";}];
          };
          "=" = {
            G = {
              contents = "contents of G";
              specs = [{a = "1";} {b = "1";} {b = "2";}];
            };
            "=" = {
              H = {
                contents = "contents of H";
                specs = [{a = "1";} {b = "1";} {c = "1";} {c = "2";}];
              };
            };
          };
        };
      }
    ]
  ];
}
