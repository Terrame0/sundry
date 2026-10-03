{sundry, ...}: rec {
  div-trunc = a: b: a / b;
  div-away = a: b: let
    inherit (sundry.math) abs;
    sign =
      if a < 0 == b < 0
      then 1
      else -1;
  in
    (abs a + abs b - 1) / abs b * sign;
  tests = [
    [(div-away 1 2) 1]
    [(div-away 2 2) 1]
    [(div-away 3 2) 2]
    [(div-away 5 3) 2]
    [(div-away 0 1) 0]
    [(div-away (-1) 2) (-1)]
    [(div-away 1 (-2)) (-1)]
    [(div-away (-1) (-2)) 1]
    [(div-away (-3) (-2)) 2]
    [(div-away (-5) 3) (-2)]
    [(div-away 4 (-2)) (-2)]
    [(div-away 0 (-1)) 0]
  ];
}
