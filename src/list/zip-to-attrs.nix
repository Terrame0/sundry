{
  sundry,
  lib,
  ...
}: rec {
  zip-to-attrs = names: values:
    lib.pipe values [
      (lib.zipListsWith
        (name: value: {${name} = value;})
        names)
      sundry.attrs.merge.no-collision
    ];

  tests = {
    empty-inputs = [(zip-to-attrs [] []) {}];
    equal-lengths = [(zip-to-attrs ["A" "B" "C"] [1 2 3]) ({A = 1;} // {B = 2;} // {C = 3;})];
    more-names-than-values = [(zip-to-attrs ["A" "B" "C"] [1 2]) ({A = 1;} // {B = 2;})];
    duplicate-names-throws = [(sundry.does-throw (zip-to-attrs ["A" "A"] [1 2])) true];
  };
}
