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
        a = {
          contents = "contents of a";
          specs = [{x = "1";}];
        };
        b = {
          contents = "contents of b";
          specs = [{x = ["2" "3"];}];
        };
        c = {
          contents = "contents of c";
          specs = [
            {
              x = "1";
              y = "1";
            }
          ];
        };
        d = {
          contents = "contents of d";
          specs = [
            {
              x = "";
              y = "";
            }
          ];
        };
        nested = {
          g = {
            contents = "contents of g";
            specs = [{x = "1";} {x = "2";}];
          };
          h = {
            contents = "contents of h";
            specs = [{y = "1";} {z = "1";}];
          };
          nested = {
            f = {
              contents = "contents of f";
              specs = [{x = "1";} {y = "1";} {y = "2";}];
            };
            nested = {
              e = {
                contents = "contents of e";
                specs = [{x = "1";} {y = "1";} {z = "1";} {z = "2";}];
              };
            };
          };
        };
      }
    ]
  ];
}
