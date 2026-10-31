{
  lib,
  sundry,
  ...
}: rec {
  clamp = x: a: b:
    if a <= b
    then lib.min b (lib.max a x)
    else throw "lower bound must be less than or equal to the upper bound";

  tests = {
    inside-range = [(clamp 1 0 2) 1];
    at-lower-bound = [(clamp 0 0 2) 0];
    at-upper-bound = [(clamp 2 0 2) 2];
    below-range = [(clamp (-1) 0 2) 0];
    above-range = [(clamp 3 0 2) 2];
    invalid-bounds = [(sundry.does-throw (clamp 0 2 1)) true];
  };
}
