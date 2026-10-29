{
  sundry,
  lib,
  ...
}: rec {
  is-dir = path: node:
    !sundry.vfs.node.is-leaf path node # -- to avoid forcing evaluation of lazy leaf payloads
    && lib.all (attrs: lib.isAttrs attrs.value) (lib.attrsToList node);

  tests = {
    nested-attrs = [(is-dir ["..."] {a = {};}) true];
    empty = [(is-dir ["..."] {}) true];
    scalar-child = [(is-dir ["..."] {a = 10;}) false];
    text-attrset = [(is-dir ["..."] {text = {};}) true];
    lazy-expr = [
      (is-dir ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      false
    ];
  };
}
