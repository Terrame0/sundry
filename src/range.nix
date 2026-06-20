{
  sundry,
  lib,
  ...
}: rec {
  range = args-list: let
    arg-count = lib.length args-list;
    arg-at = i: sundry.list.at i args-list;
    args = sundry.switch arg-count [
      [0 (throw "\nnot enough arguments for 'range' (got ${toString arg-count})")]
      [
        [1 2 3]
        rec {
          start =
            if arg-count >= 2
            then arg-at 0
            else 0;
          count = let
            base =
              if arg-count == 1
              then arg-at 0
              else arg-at 1;
            diff = base - start;
          in
            diff / step + sundry.math.abs (lib.mod diff step);
          step =
            if arg-count == 3
            then arg-at 2
            else 1;
        }
      ]
      (throw "\ntoo many arguments for 'range' (got ${toString arg-count})")
    ];
  in
    lib.genList (i: args.start + i * args.step) (lib.max 0 args.count);
  tests = [
    [(range [5]) [0 1 2 3 4]]
    [(range [0]) []]
    [(range [2 5]) [2 3 4]]
    [(range [3 3]) []]
    [(range [1 6 2]) [1 3 5]]
    [(range [5 2 (-2)]) [5 3]]
    [(range [0 5 (-1)]) []]
    [(sundry.does-throw (range [])) true]
    [(sundry.does-throw (range [1 2 3 4])) true]
  ];
}
