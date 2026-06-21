{
  lib,
  sundry,
  ...
}: rec {
  matches = tag-spec: tag-set: let
    wanted-diff = lib.pipe tag-spec [
      (lib.filterAttrs (_: spec: spec != null))
      (sundry.attrs.compare tag-set)
    ];
    wanted-present = wanted-diff.missing == {};
    wanted-matched =
      lib.all lib.id
      (lib.mapAttrsToList (key: pair: let
        values = lib.toList (sundry.list.at 0 pair);
        spec = lib.toList (sundry.list.at 1 pair);
        parts = lib.partition sundry.vfs.tag.is-excluded spec;
        wanted-values = parts.wrong;
        unwanted-values = map sundry.vfs.tag.unwrap-excluded parts.right;
      in
        (wanted-values == [] || sundry.list.intersect values wanted-values != [])
        && sundry.list.intersect values unwanted-values == [])
      wanted-diff.matched);
    unwanted-diff = lib.pipe tag-spec [
      (lib.filterAttrs (_: spec: spec == null))
      (sundry.attrs.compare tag-set)
    ];
    unwanted-absent = unwanted-diff.matched == {};
  in
    wanted-present && wanted-matched && unwanted-absent;

  tests = let
    inherit (sundry.vfs.tag) exclude;
    tag-set = {x = "1";} // {y = "1";};
    composite = {x = ["1" "2"];};
  in [
    [(matches {x = "1";} tag-set) true]
    [(matches {x = "2";} tag-set) false]
    [(matches {x = ["1" "2"];} tag-set) true]
    [(matches ({x = "1";} // {y = "1";}) tag-set) true]
    [(matches ({x = "1";} // {y = "2";}) tag-set) false]
    [(matches {x = null;} tag-set) false]
    [(matches {w = null;} tag-set) true]
    [(matches ({x = "1";} // {w = null;}) tag-set) true]
    [(matches ({x = "1";} // {y = null;}) tag-set) false]
    [(matches {x = "1";} composite) true]
    [(matches {x = "3";} composite) false]
    [(matches {x = ["1" "2"];} composite) true]
    [(matches {x = [];} composite) true]
    [(matches {x = exclude "1";} tag-set) false]
    [(matches {x = exclude "2";} tag-set) true]
    [(matches {x = ["1" (exclude "2")];} tag-set) true]
    [(matches {x = ["1" (exclude "1")];} tag-set) false]
    [(matches {x = exclude "1";} composite) false]
    [(matches {x = exclude "3";} composite) true]
    [(matches {z = exclude "1";} tag-set) false]
  ];
}
