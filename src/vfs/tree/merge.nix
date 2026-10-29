{sundry, ...}: {
  merge = lhs: rhs: sundry.attrs.merge.dirs.no-collision [lhs rhs];
  merge-n = sundry.attrs.merge.dirs.no-collision;
  tests = {
    disjoint = [
      (sundry.vfs.tree.merge
        {
          A = {
            "B.txt" = {
              text = "b";
            };
          };
        }
        {
          A = {
            "C.txt" = {
              text = "c";
            };
          };
          D = {
            "E.txt" = {
              text = "e";
            };
          };
        })
      {
        A = {
          "B.txt" = {
            text = "b";
          };
          "C.txt" = {
            text = "c";
          };
        };
        D = {
          "E.txt" = {
            text = "e";
          };
        };
      }
    ];
    empty = [
      (sundry.vfs.tree.merge {} {})
      {}
    ];
    into-empty = [
      (sundry.vfs.tree.merge
        {}
        {
          "A.txt" = {
            text = "a";
          };
        })
      {
        "A.txt" = {
          text = "a";
        };
      }
    ];
    throws-on-file-collision = [
      (sundry.does-throw (sundry.vfs.tree.merge
        {
          "A.txt" = {
            text = "a";
          };
        }
        {
          "A.txt" = {
            text = "a";
          };
        }))
      true
    ];
    throws-on-file-dir-collision = [
      (sundry.does-throw (sundry.vfs.tree.merge
        {
          A = {
            text = "a";
          };
        }
        {
          A = {
            "B.txt" = {
              text = "b";
            };
          };
        }))
      true
    ];
  };
}
