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

  tests = {
    one-over-two = [(div-away 1 2) 1];
    two-over-two = [(div-away 2 2) 1];
    three-over-two = [(div-away 3 2) 2];
    five-over-three = [(div-away 5 3) 2];
    zero-over-one = [(div-away 0 1) 0];
    negative-over-positive = [(div-away (-1) 2) (-1)];
    positive-over-negative = [(div-away 1 (-2)) (-1)];
    negative-over-negative = [(div-away (-1) (-2)) 1];
    negative-three-over-negative-two = [(div-away (-3) (-2)) 2];
    negative-five-over-positive-three = [(div-away (-5) 3) (-2)];
    positive-four-over-negative-two = [(div-away 4 (-2)) (-2)];
    zero-over-negative-one = [(div-away 0 (-1)) 0];
  };
}
