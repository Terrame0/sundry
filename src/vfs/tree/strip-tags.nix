{sundry, ...}: rec {
  strip-tags =
    sundry.vfs.tree.reform
    (path: node: {
      path = sundry.vfs.path.strip-between "{" "}" path;
      value = removeAttrs node ["tag-list"];
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
  in {
    dirty-tree = [
      (strip-tags dirty)
      {
        "=" = {
          "F" = {
            text = "contents of F";
            origin = "/F";
          };
        };
      }
    ];
    resolved-tree = [
      (strip-tags resolved)
      {
        A = {
          text = "contents of A";
          origin = "/A";
        };
      }
    ];
    idempotent = [
      (strip-tags (strip-tags dirty))
      (strip-tags dirty)
    ];
  };
}
