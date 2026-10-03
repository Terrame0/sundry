{
  sundry,
  lib,
  ...
}: rec {
  slice = args-list: str:
    lib.foldl (acc: i: acc + sundry.str.at i str)
    "" (sundry.range args-list);
  tests = [
    [(slice [2] "abc") "ab"]
    [(slice [1 2] "abc") "b"]
    [(slice [0 3 2] "abc") "ac"]
    [(slice [2 (-1) (-1)] "abc") "cba"]
    [(slice [1 (-2) (-1)] "abc") "bac"]
    [(slice [3 0] "abc") ""]
    [(slice [0 3 (-1)] "abc") ""]
    [(slice [1 1] "abc") ""]
    [(slice [0 5 3] "abcdefg") "ad"]
  ];
}
