{
  lib,
  sundry,
  ...
}: {
  switch = value: cases: let
    recurse = left: let
      case = lib.head left;
      expected = sundry.list.at 0 case;
      result = sundry.list.at 1 case;
    in
      if lib.length left == 1
      then lib.head left
      else if value == expected
      then result
      else recurse (lib.tail left);
  in
    recurse cases;
}
