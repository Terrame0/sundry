{
  lib,
  sundry,
  ...
}: rec {
  clamp = x: a: b:
    if a <= b
    then lib.min b (lib.max a x)
    else throw "lower bound must be less than or equal to the upper bound";
  tests = [
    [(clamp 1 0 2) 1]
    [(clamp 0 0 2) 0]
    [(clamp 2 0 2) 2]
    [(clamp (-1) 0 2) 0]
    [(clamp 3 0 2) 2]
    [(sundry.does-throw (clamp 0 2 1)) true]
  ];
}
