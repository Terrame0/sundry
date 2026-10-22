{
  sundry,
  lib,
  ...
}: rec {
  is-dir = path: node:
    !is-leaf path node # -- to avoid forcing evaluation of lazy leaf payloads
    && lib.all lib.id (lib.mapAttrsToList (name: value: lib.isAttrs value) node);
  is-leaf = _: node: let
    text = node.text or null;
    origin = node.origin or null;
  in
    lib.isPath origin
    || lib.isString origin
    || lib.isDerivation origin
    || lib.isString text;
  is-leaf-node = path: node:
    if !lib.isAttrs node
    then throw "\nvfs directory node at '/${sundry.vfs.path.get.str path}' is not an attribute set"
    else if is-leaf path node
    then true
    else if is-dir path node
    then false
    else throw "\nvfs directory node at '/${sundry.vfs.path.get.str path}' is neither a leaf nor a directory";
  tests = {
    is-dir-nested-attrs = [(is-dir "..." {a = {};}) true];
    is-dir-empty = [(is-dir "..." {}) true];
    is-dir-scalar-child = [(is-dir "..." {a = 10;}) false];
    is-dir-lazy-expr = [
      (is-dir "..." {
        origin = "...";
        expr = throw "expr was forced";
      })
      false
    ];
    is-leaf-text = [(is-leaf "..." {text = "...";}) true];
    is-leaf-path-origin = [(is-leaf "..." {origin = ./node-cond.nix;}) true];
    # -- a materialized file drops 'text' and downstream stages may re-point
    # - 'origin' at a derivation, so a derivation-only node is still a leaf
    is-leaf-derivation-origin = [(is-leaf "..." {origin = {type = "derivation";};}) true];
    is-leaf-node-derivation-origin = [(is-leaf-node "..." {origin = {type = "derivation";};}) true];
    is-leaf-lazy-expr = [
      (is-leaf "..." {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
    is-leaf-lazy-text = [
      (is-leaf "..." {
        origin = "...";
        text = throw "text was forced";
      })
      true
    ];
    is-leaf-unknown-attr = [(is-leaf "..." {expr = 10;}) false];
    is-leaf-nested-dir = [(is-leaf "..." {file = {text = "...";};}) false];
    is-leaf-non-string-text = [(is-leaf "..." {text = {};}) false];
    is-leaf-node-text = [(is-leaf-node "..." {text = "...";}) true];
    is-leaf-node-lazy-expr = [
      (is-leaf-node "..." {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
    is-leaf-node-directory = [(is-leaf-node "..." {a = {};}) false];
    throws-on-non-dir-child = [(sundry.does-throw (is-leaf-node ["x" "y" "z"] {a = 10;})) true];
    throws-on-non-attrs = [(sundry.does-throw (is-leaf-node ["x" "y" "z"] 10)) true];
  };
}
