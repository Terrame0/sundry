{
  sundry,
  lib,
  ...
}: rec {
  halt = path: node:
    if !lib.isAttrs node
    then throw "vfs directory node at ${sundry.str.pretty path} is not an attribute set"
    else if sundry.vfs.node.is-leaf path node
    then true
    else if sundry.vfs.node.is-dir path node
    then false
    else throw "vfs directory node at ${sundry.str.pretty path} is neither a leaf nor a directory";

  tests = {
    leaf = [(halt ["..."] {text = "...";}) true];
    opaque-leaf = [(halt ["..."] {origin = "...";}) true];
    directory = [(halt ["..."] {a = {};}) false];
    empty-directory = [(halt ["..."] {}) false];
    text-attrset-directory = [(halt ["..."] {text = {};}) false];
    throws-on-invalid-node = [(sundry.does-throw (halt ["x"] {a = 10;})) true];
    throws-on-non-attrs = [(sundry.does-throw (halt ["x"] 10)) true];
    lazy-expr = [
      (halt ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
  };
}
