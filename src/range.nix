{
  sundry,
  lib,
  ...
}: rec {
  range = args-list: let
    arg-count = lib.length args-list;
    arg-at = i: sundry.list.at i args-list;
    args = sundry.switch arg-count [
      [0 (throw "not enough arguments for 'range' (got ${toString arg-count})")]
      [
        [1 2 3]
        rec {
          start =
            if arg-count == 1
            then 0
            else arg-at 0;
          count = let
            base =
              if arg-count == 1
              then arg-at 0
              else arg-at 1;
            diff = base - start;
          in
            sundry.math.div-away diff step;
          step =
            if arg-count == 3
            then arg-at 2
            else 1;
        }
      ]
      (throw "too many arguments for 'range' (got ${toString arg-count})")
    ];
  in
    lib.genList (i: args.start + i * args.step) (lib.max 0 args.count);

  tests = {
    empty-negative-step = [(range [0 2 (-3)]) []];
    single-argument = [(range [5]) [0 1 2 3 4]];
    zero-count = [(range [0]) []];
    two-arguments = [(range [2 5]) [2 3 4]];
    equal-endpoints = [(range [3 3]) []];
    step-two = [(range [1 6 2]) [1 3 5]];
    step-three = [(range [1 7 3]) [1 4]];
    step-three-remainder = [(range [1 8 3]) [1 4 7]];
    negative-step = [(range [5 2 (-2)]) [5 3]];
    negative-step-to-zero = [(range [3 0 (-1)]) [3 2 1]];
    negative-step-three = [(range [5 0 (-3)]) [5 2]];
    negative-start = [(range [(-2) 2]) [(-2) (-1) 0 1]];
    empty-negative-step-from-zero = [(range [0 5 (-1)]) []];
    no-arguments = [(sundry.does-throw (range [])) true];
    too-many-arguments = [(sundry.does-throw (range [1 2 3 4])) true];
  };
}
