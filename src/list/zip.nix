{
  sundry,
  lib,
  ...
}: rec {
  zip = lists:
    lib.forEach
    (sundry.range [(sundry.list.min (map lib.length lists))])
    (i: map (sundry.list.at i) lists);
  tests = [
    [(zip [[1 2 3] [4 5] [6 7]]) [[1 4 6] [2 5 7]]]
  ];
}
