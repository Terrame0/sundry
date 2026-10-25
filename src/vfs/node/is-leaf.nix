{
  lib,
  sundry,
  ...
}: rec {
  is-leaf = _: node: let
    text = node.text or null;
    origin = node.origin or null;
  in
    lib.any (sundry.apply origin) (with lib; [isPath isString isDerivation])
    || lib.isString text;

  tests = {
    is-leaf-text = [(is-leaf ["..."] {text = "...";}) true];
    is-leaf-path-origin = [(is-leaf ["..."] {origin = ./is-leaf.nix;}) true];
    # -- a materialized file drops 'text' and downstream stages may re-point
    # - 'origin' at a derivation, so a derivation-only node is still a leaf
    is-leaf-derivation-origin = [(is-leaf ["..."] {origin = {type = "derivation";};}) true];
    is-leaf-lazy-expr = [
      (is-leaf ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
    is-leaf-lazy-text = [
      (is-leaf ["..."] {
        origin = "...";
        text = throw "text was forced";
      })
      true
    ];
    is-leaf-unknown-attr = [(is-leaf ["..."] {expr = 10;}) false];
    is-leaf-nested-dir = [(is-leaf ["..."] {file = {text = "...";};}) false];
    is-leaf-non-string-text = [(is-leaf ["..."] {text = {};}) false];
  };
}
