{...}: rec {
  is-leaf = _: attrs:
    builtins.isString (attrs.text or null)
    || builtins.isString (attrs.src or null);
  tests = [
    [(is-leaf "..." {text = "...";}) true]
    [(is-leaf "..." {file = {text = "...";};}) false]
    [(is-leaf "..." {text = {};}) false]
  ];
}
