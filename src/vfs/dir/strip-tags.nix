{
  sundry,
  ...
}: rec {
  strip-tags =
    sundry.attrs.reform-until
    sundry.vfs.is-leaf-node
    (path: value: {
      path = sundry.vfs.path.strip-between "{" "}" path;
      value = removeAttrs value ["tag-list"];
    });
  tests = let
    dirty = {
      "={a:1}" = {
        "F{a:2}" = {
          text = "contents of F";
          origin = "/F";
        };
      };
    };
    resolved = {
      A = {
        text = "contents of A";
        origin = "/A";
        tag-list = [{a = "1";}];
      };
    };
  in [
    [
      (strip-tags dirty)
      {
        "=" = {
          "F" = {
            text = "contents of F";
            origin = "/F";
          };
        };
      }
    ]
    [
      (strip-tags resolved)
      {
        A = {
          text = "contents of A";
          origin = "/A";
        };
      }
    ]
    [
      (strip-tags (strip-tags dirty))
      (strip-tags dirty)
    ]
  ];
}
