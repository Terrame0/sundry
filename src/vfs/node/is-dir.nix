{
  sundry,
  lib,
  ...
}: rec {
  is-dir = path: node:
    !sundry.vfs.node.is-leaf path node # -- to avoid forcing evaluation of lazy leaf payloads
    && lib.all (attrs: lib.isAttrs attrs.value) (lib.attrsToList node);

  tests = {
    is-dir-nested-attrs = [(is-dir ["..."] {a = {};}) true];
    is-dir-empty = [(is-dir ["..."] {}) true];
    is-dir-scalar-child = [(is-dir ["..."] {a = 10;}) false];
    is-dir-lazy-expr = [
      (is-dir ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      false
    ];
  };
}
