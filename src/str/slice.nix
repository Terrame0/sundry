{
  sundry,
  lib,
  ...
}: rec {
  slice = str: args-list:
    lib.foldl (acc: i: acc + sundry.str.at i str)
    "" (sundry.range args-list);
  tests = [
    [(slice "abc" [2]) "ab"]
    [(slice "abc" [1 2]) "b"]
    [(slice "abc" [0 3 2]) "ac"]
    [(slice "abc" [2 (-1) (-1)]) "cba"]
    [(slice "abc" [1 (-2) (-1)]) "bac"]
    [(slice "abc" [3 0]) ""]
    [(slice "abc" [0 3 (-1)]) ""]
    [(slice "abc" [1 1]) ""]
    [(slice "abcdefg" [0 5 3]) "ad"]
  ];
}
