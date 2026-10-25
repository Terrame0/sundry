{
  sundry,
  lib,
  ...
}: rec {
  validate = path: node:
    if !lib.isAttrs node
    then throw "vfs directory node at '${sundry.vfs.path.get.str path}' is not an attribute set"
    else if lib.any (sundry.apply [path node]) (with sundry.vfs.node; [is-leaf is-dir])
    then true
    else throw "vfs directory node at '${sundry.vfs.path.get.str path}' is neither a leaf nor a directory";

  tests = {
    validate-derivation-origin = [(validate ["..."] {origin = {type = "derivation";};}) true];
    validate-text = [(validate ["..."] {text = "...";}) true];
    validate-directory = [(validate ["..."] {a = {};}) true];
    throws-on-non-dir-child = [(sundry.does-throw (validate ["x" "y" "z"] {a = 10;})) true];
    throws-on-non-attrs = [(sundry.does-throw (validate ["x" "y" "z"] 10)) true];
    validate-lazy-expr = [
      (validate ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
  };
}
