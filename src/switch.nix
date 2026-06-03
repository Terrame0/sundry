{
  lib,
  mlem,
  ...
}: {
  switch = value: cases: let
    recurse = left: let
      case = lib.head left;
      expected = mlem.list.at 0 case;
      result = mlem.list.at 1 case;
    in
      if lib.length left == 1
      then lib.head left
      else if value == expected
      then result
      else recurse (lib.tail left);
  in
    recurse cases;
}
