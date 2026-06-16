{...}: rec {
  is-leaf = _: attrs: builtins.isString (attrs.contents or null);
  tests = [
    [(is-leaf "..." {contents = "...";}) true]
    [(is-leaf "..." {file = {contents = "...";};}) false]
    [(is-leaf "..." {contents = {};}) false]
  ];
}
