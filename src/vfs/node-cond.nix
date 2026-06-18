{
  mlem,
  lib,
  ...
}: rec {
  is-dir = _: attrs: lib.all lib.id (lib.mapAttrsToList (name: value: lib.isAttrs value) attrs);
  is-leaf = _: attrs: let
    text = attrs.text or null;
    src = attrs.src or null;
  in
    lib.isString text
    || lib.isString src
    || lib.isDerivation src
    || lib.isDerivation attrs;
  is-leaf-node = path: attrs:
    if is-leaf path attrs
    then true
    else if is-dir path attrs
    then false
    else throw "\nvfs directory node at '/${mlem.vfs.path.get.str path}' is neither a leaf nor a directory";
  tests = [
    [(is-dir "..." {a = {};}) true]
    [(is-dir "..." {}) true]
    [(is-dir "..." {a = 10;}) false]
    [(is-leaf "..." {text = "...";}) true]
    [(is-leaf "..." {file = {text = "...";};}) false]
    [(is-leaf "..." {text = {};}) false]
    [(is-leaf-node "..." {text = "...";}) true]
    [(is-leaf-node "..." {a = {};}) false]
    [(builtins.tryEval (is-leaf-node ["x" "y" "z"] {a = 10;})).success false]
  ];
}
