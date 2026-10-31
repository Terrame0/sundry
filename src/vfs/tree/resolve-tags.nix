{
  lib,
  sundry,
  fixtures-dir,
  ...
}: rec {
  resolve-tags =
    sundry.vfs.tree.reform
    (path: node:
      if node ? tag-list
      then throw "vfs.tree.resolve-tags: node at ${sundry.str.pretty path} already has 'tag-list'"
      else {
        path = sundry.vfs.path.strip-between "{" "}" path;
        value =
          node
          // {
            tag-list = map (dir:
              lib.pipe dir [
                (sundry.str.between "{" "}")
                (map (tag-str: let
                  tag-parts = sundry.str.split ":" tag-str;
                  tag-key = lib.head tag-parts;
                  tag-value = sundry.is-null (sundry.list.excl-last tag-parts) "";
                  tag-list = sundry.str.split "," tag-value;
                in {
                  ${tag-key} = sundry.list.un-singleton tag-list;
                }))
                sundry.attrs.merge.no-collision
              ])
            path;
          };
      });

  tests = {
    tagged-tree = [
      (lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
        sundry.vfs.tree.from-src
        resolve-tags
      ])
      {
        A = {
          origin = fixtures-dir + "/vfs-test-dir/tags/A{a:1}";
          tag-list = [{a = "1";}];
        };
        B = {
          origin = fixtures-dir + "/vfs-test-dir/tags/B{a:2,3}";
          tag-list = [{a = ["2" "3"];}];
        };
        C = {
          origin = fixtures-dir + "/vfs-test-dir/tags/C{a:1}{b:1}";
          tag-list = [({a = "1";} // {b = "1";})];
        };
        D = {
          origin = fixtures-dir + "/vfs-test-dir/tags/D{a}{b:}";
          tag-list = [({a = "";} // {b = "";})];
        };
        E = {
          origin = fixtures-dir + "/vfs-test-dir/tags/E";
          tag-list = [{}];
        };
        "=" = {
          F = {
            origin = fixtures-dir + "/vfs-test-dir/tags/={a:1}/F{a:2}";
            tag-list = [{a = "1";} {a = "2";}];
          };
          I = {
            origin = fixtures-dir + "/vfs-test-dir/tags/={b:1}/I{c:1}";
            tag-list = [{b = "1";} {c = "1";}];
          };
          "=" = {
            G = {
              origin = fixtures-dir + "/vfs-test-dir/tags/={a:1}/={b:1}/G{b:2}";
              tag-list = [{a = "1";} {b = "1";} {b = "2";}];
            };
            "=" = {
              H = {
                origin = fixtures-dir + "/vfs-test-dir/tags/={a:1}/={b:1}/={c:1}/H{c:2}";
                tag-list = [{a = "1";} {b = "1";} {c = "1";} {c = "2";}];
              };
            };
          };
        };
      }
    ];
    collision-lazy = [
      (sundry.does-throw-whnf (resolve-tags {
        "A{a:1}" = {
          text = "abc";
          origin = "/A";
        };
        "A{a:2}" = {
          text = "def";
          origin = "/A";
        };
      }))
      false
    ];
    throws-on-collision = [
      (sundry.does-throw (resolve-tags {
        "A{a:1}" = {
          text = "abc";
          origin = "/A";
        };
        "A{a:2}" = {
          text = "def";
          origin = "/A";
        };
      }))
      true
    ];
    throws-on-resolved-tag = [
      (sundry.does-throw (resolve-tags {
        A = {
          text = "abc";
          origin = "/A";
          tag-list = [{}];
        };
      }))
      true
    ];
  };
}
