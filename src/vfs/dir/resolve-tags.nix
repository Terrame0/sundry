{
  lib,
  mlem,
  flake-root,
  ...
}: rec {
  resolve-tags = args-in: let
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
    mlem.vfs.is-leaf-node
    (path: value: {
      path =
        if args.strip
        then mlem.vfs.path.strip-between lsep rsep path
        else path;
      value =
        value
        // {
          tags = map (dir:
            lib.pipe dir [
              (mlem.str.between lsep rsep)
              (map (tag-str: let
                tag-parts = lib.splitString kvsep tag-str;
                tag-key = lib.head tag-parts;
                tag-value = mlem.is-null (mlem.list.excl-last tag-parts) "";
                tag-list = lib.splitString vsep tag-value;
              in {
                ${tag-key} = mlem.list.un-singleton tag-list;
              }))
              mlem.attrs.merge.no-collision
            ])
          path;
        };
    });
  tests = [
    [
      (lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
        mlem.vfs.dir.from-src
        (resolve-tags {
          strip = true;
          separators = ["{" ":" "," "}"];
        })
      ])
      {
        A = {
          text = "contents of A";
          tags = [{a = "1";}];
        };
        B = {
          text = "contents of B";
          tags = [{a = ["2" "3"];}];
        };
        C = {
          text = "contents of C";
          tags = [
            {
              a = "1";
              b = "1";
            }
          ];
        };
        D = {
          text = "contents of D";
          tags = [
            {
              a = "";
              b = "";
            }
          ];
        };
        E = {
          text = "contents of E";
          tags = [{}];
        };
        "=" = {
          F = {
            text = "contents of F";
            tags = [{a = "1";} {a = "2";}];
          };
          I = {
            text = "contents of I";
            tags = [{b = "1";} {c = "1";}];
          };
          "=" = {
            G = {
              text = "contents of G";
              tags = [{a = "1";} {b = "1";} {b = "2";}];
            };
            "=" = {
              H = {
                text = "contents of H";
                tags = [{a = "1";} {b = "1";} {c = "1";} {c = "2";}];
              };
            };
          };
        };
      }
    ]
  ];
}
