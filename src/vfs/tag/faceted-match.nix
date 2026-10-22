{
  lib,
  sundry,
  ...
}: rec {
  faceted-match = tag-set: tag-spec: let
    diff = sundry.attrs.compare tag-set tag-spec;
    present = diff.missing == {};
    matched =
      lib.all lib.id
      (lib.mapAttrsToList (key: pair: let
        decomposed = sundry.list.zip-to-attrs ["values" "wanted-values"] pair;
        inherit (decomposed) values wanted-values;
      in
        wanted-values == [] || sundry.list.intersect (lib.toList values) (lib.toList wanted-values) != [])
      diff.matched);
  in
    present && matched;

  tests = let
    tag-set = {a = "1";} // {b = ["1" "2"];};
  in {
    matching-scalar = [(faceted-match tag-set {a = "1";}) true];
    matching-list = [(faceted-match tag-set {b = "2";}) true];
    missing-value = [(faceted-match tag-set {a = "9";}) false];
    missing-key = [(faceted-match tag-set {c = "1";}) false];
    empty-wanted = [(faceted-match tag-set {a = [];}) true];
    empty-wanted-missing-key = [(faceted-match tag-set {c = [];}) false];
    one-matches-one-missing = [(faceted-match tag-set ({a = "1";} // {b = "9";})) false];
    list-intersection = [(faceted-match tag-set {b = ["9" "2"];}) true];
    scalar-in-list = [(faceted-match tag-set {a = ["9" "1"];}) true];
    empty-spec = [(faceted-match tag-set {}) true];
    empty-both = [(faceted-match {} {}) true];
    empty-set-nonempty-spec = [(faceted-match {} {a = "1";}) false];
  };
}
