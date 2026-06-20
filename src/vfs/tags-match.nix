{
  lib,
  sundry,
  ...
}: rec {
  tags-match = tag-spec: tag-set: let
    wanted-diff = lib.pipe tag-spec [
      (lib.filterAttrs (_: spec: spec != null))
      (sundry.attrs.compare tag-set)
    ];
    wanted-present = wanted-diff.missing == {};
    wanted-matched =
      lib.all lib.id
      (lib.mapAttrsToList (key: pair:
        lib.any
        (value: sundry.list.contains (sundry.list.at 1 pair) value)
        (lib.toList (sundry.list.at 0 pair))
        || (sundry.list.at 1 pair) == [])
      wanted-diff.matched);
    unwanted-diff = lib.pipe tag-spec [
      (lib.filterAttrs (_: spec: spec == null))
      (sundry.attrs.compare tag-set)
    ];
    unwanted-absent = unwanted-diff.matched == {};
  in
    wanted-present && wanted-matched && unwanted-absent;

  tests = let
    tag-set = {x = "1";} // {y = "1";};
    composite = {x = ["1" "2"];};
  in [
    [(tags-match {x = "1";} tag-set) true]
    [(tags-match {x = "2";} tag-set) false]
    [(tags-match {x = ["1" "2"];} tag-set) true]
    [(tags-match ({x = "1";} // {y = "1";}) tag-set) true]
    [(tags-match ({x = "1";} // {y = "2";}) tag-set) false]
    [(tags-match {x = null;} tag-set) false]
    [(tags-match {w = null;} tag-set) true]
    [(tags-match ({x = "1";} // {w = null;}) tag-set) true]
    [(tags-match ({x = "1";} // {y = null;}) tag-set) false]
    [(tags-match {x = "1";} composite) true]
    [(tags-match {x = "3";} composite) false]
    [(tags-match {x = ["1" "2"];} composite) true]
    [(tags-match {x = [];} composite) true]
  ];
}
