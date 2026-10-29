{
  sundry,
  lib,
  ...
}: rec {
  validate = path: node:
    lib.seq (sundry.vfs.node.halt path node) true;

  tests = {
    derivation-origin = [(validate ["..."] {origin = {type = "derivation";};}) true];
    text = [(validate ["..."] {text = "...";}) true];
    directory = [(validate ["..."] {a = {};}) true];
    empty-directory = [(validate ["..."] {}) true];
    text-attrset-directory = [(validate ["..."] {text = {};}) true];
    throws-on-non-dir-child = [(sundry.does-throw (validate ["x" "y" "z"] {a = 10;})) true];
    throws-on-non-attrs = [(sundry.does-throw (validate ["x" "y" "z"] 10)) true];
    lazy-expr = [
      (validate ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
  };
}
