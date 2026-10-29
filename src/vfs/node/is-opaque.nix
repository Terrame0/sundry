{
  sundry,
  lib,
  ...
}: rec {
  is-opaque = path: node:
    sundry.vfs.node.is-leaf path node && !node ? text;

  tests = {
    path-origin = [(is-opaque ["..."] {origin = ./is-opaque.nix;}) true];
    string-origin = [(is-opaque ["..."] {origin = "...";}) true];
    derivation-origin = [(is-opaque ["..."] {origin = {type = "derivation";};}) true];
    keeps-metadata = [
      (is-opaque ["..."] {
        origin = "...";
        tag-list = [];
      })
      true
    ];
    lazy-expr = [
      (is-opaque ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
    authored = [(is-opaque ["..."] {text = "...";}) false];
    authored-with-origin = [
      (is-opaque ["..."] {
        origin = "...";
        text = "...";
      })
      false
    ];
    lazy-text = [
      (sundry.does-throw-whnf
        (is-opaque ["..."] {
          origin = "...";
          text = throw "text was forced";
        }))
      false
    ];
    directory = [(is-opaque ["..."] {A = {};}) false];
    empty-directory = [(is-opaque ["..."] {}) false];
    non-string-text = [(is-opaque ["..."] {text = {};}) false];
    non-attrs = [(is-opaque ["..."] 10) false];
  };
}
