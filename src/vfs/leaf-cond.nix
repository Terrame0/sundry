{...}: rec {
  is-leaf = attrs: builtins.isString (attrs.contents or null);
  is-not-leaf = attrs: !(is-leaf attrs);
  tests = [
    [(is-leaf {contents = "...";}) true]
    [(is-leaf {file = {contents = "...";};}) false]
    [(is-leaf {contents = {};}) false]
  ];
}
