{
  lib,
  sundry,
  ...
}: {
  tag = tag-set: tag-spec: let
    diff = sundry.attrs.compare tag-set tag-spec;
    present = diff.missing == {};
    matched =
      lib.all lib.id
      (lib.mapAttrsToList (key: pair: let
        values = lib.toList (sundry.list.at 0 pair);
        wanted-values = lib.toList (sundry.list.at 1 pair);
      in
        wanted-values == [] || sundry.list.intersect values wanted-values != [])
      diff.matched);
  in
    present && matched;
}
