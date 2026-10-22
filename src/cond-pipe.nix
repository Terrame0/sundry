{
  sundry,
  lib,
  ...
}: {
  cond-pipe = init: pipe:
    lib.foldl
    (acc: pair: let
      decomposed = sundry.list.zip-to-attrs ["bool" "fn"] pair;
      inherit (decomposed) bool fn;
    in
      if bool
      then fn acc
      else acc)
    init
    pipe;

  tests = {
    empty-pipe = [(sundry.cond-pipe 0 []) 0];
    all-true = [
      (sundry.cond-pipe 1 [
        [true (x: x + 10)]
        [true (x: x * 2)]
      ])
      22
    ];
    first-false = [
      (sundry.cond-pipe 1 [
        [false (x: x + 10)]
        [true (x: x * 2)]
      ])
      2
    ];
    all-false = [
      (sundry.cond-pipe 1 [
        [false (x: x + 10)]
        [false (x: x * 2)]
      ])
      1
    ];
  };
}
