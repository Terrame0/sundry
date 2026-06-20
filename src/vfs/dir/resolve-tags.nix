{
  lib,
  sundry,
  flake-root,
  ...
}: rec {
  resolve-tags = args-in: let
    args =
      sundry.attrs.validate {
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
      }
      args-in;
    lsep = sundry.list.at 0 args.separators;
    kvsep = sundry.list.at 1 args.separators;
    vsep = sundry.list.at 2 args.separators;
    rsep = sundry.list.at 3 args.separators;
  in
    sundry.attrs.reform-until
    sundry.vfs.is-leaf-node
    (path: value: {
      path =
        if args.strip
        then sundry.vfs.path.strip-between lsep rsep path
        else path;
      value =
        value
        // {
          tag-list = map (dir:
            lib.pipe dir [
              (sundry.str.between lsep rsep)
              (map (tag-str: let
                tag-parts = lib.splitString kvsep tag-str;
                tag-key = lib.head tag-parts;
                tag-value = sundry.is-null (sundry.list.excl-last tag-parts) "";
                tag-list = lib.splitString vsep tag-value;
              in {
                ${tag-key} = sundry.list.un-singleton tag-list;
              }))
              sundry.attrs.merge.no-collision
            ])
          path;
        };
    });
  tests = [
    [
      (lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
        sundry.vfs.dir.from-src
        (resolve-tags {
          strip = true;
          separators = ["{" ":" "," "}"];
        })
      ])
      {
        A = {
          text = "contents of A";
          tag-list = [{a = "1";}];
        };
        B = {
          text = "contents of B";
          tag-list = [{a = ["2" "3"];}];
        };
        C = {
          text = "contents of C";
          tag-list = [({a = "1";} // {b = "1";})];
        };
        D = {
          text = "contents of D";
          tag-list = [({a = "";} // {b = "";})];
        };
        E = {
          text = "contents of E";
          tag-list = [{}];
        };
        "=" = {
          F = {
            text = "contents of F";
            tag-list = [{a = "1";} {a = "2";}];
          };
          I = {
            text = "contents of I";
            tag-list = [{b = "1";} {c = "1";}];
          };
          "=" = {
            G = {
              text = "contents of G";
              tag-list = [{a = "1";} {b = "1";} {b = "2";}];
            };
            "=" = {
              H = {
                text = "contents of H";
                tag-list = [{a = "1";} {b = "1";} {c = "1";} {c = "2";}];
              };
            };
          };
        };
      }
    ]
  ];
}
