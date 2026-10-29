{
  lib,
  sundry,
  ...
}: rec {
  is-leaf = _: node: let
    text = node.text or null;
    origin = node.origin or null;
  in
    lib.any (sundry.apply [origin]) (with lib; [isPath isString isDerivation])
    || lib.isString text;

  tests = {
    text = [(is-leaf ["..."] {text = "...";}) true];
    path-origin = [(is-leaf ["..."] {origin = ./is-leaf.nix;}) true];
    string-origin = [(is-leaf ["..."] {origin = "...";}) true];
    # -- a materialized file drops 'text' and downstream stages may re-point
    # - 'origin' at a derivation, so a derivation-only node is still a leaf
    derivation-origin = [(is-leaf ["..."] {origin = {type = "derivation";};}) true];
    lazy-expr = [
      (is-leaf ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
    lazy-text = [
      (is-leaf ["..."] {
        origin = "...";
        text = throw "text was forced";
      })
      true
    ];
    unknown-attr = [(is-leaf ["..."] {expr = 10;}) false];
    nested-dir = [(is-leaf ["..."] {file = {text = "...";};}) false];
    non-string-text = [(is-leaf ["..."] {text = {};}) false];
  };
}
