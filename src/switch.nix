{
  lib,
  sundry,
  ...
}: rec {
  switch = value: cases: let
    recurse = left: let
      case = lib.head left;
      expected = sundry.list.at 0 case;
      result = sundry.list.at 1 case;
    in
      if lib.length left == 1
      then lib.head left
      else if
        if lib.isFunction expected
        then expected value
        else sundry.list.contains expected value
      then result
      else recurse (lib.tail left);
  in
    recurse cases;

  tests = {
    match-second-case = [
      (switch "B" [
        [["A"] "1"]
        [["B"] "2"]
        "3"
      ])
      "2"
    ];
    default-case = [
      (switch "C" [
        [["A"] "1"]
        [["B"] "2"]
        "3"
      ])
      "3"
    ];
    multi-value-match = [
      (switch "B" [
        [["A" "B"] "1"]
        "2"
      ])
      "1"
    ];
    predicate-match = [
      (switch 5 [
        [(x: x > 3) "1"]
        "2"
      ])
      "1"
    ];
  };
}
