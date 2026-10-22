{
  sundry,
  lib,
  ...
}: rec {
  slice = args-list: str:
    lib.foldl (acc: i: acc + sundry.str.at i str)
    "" (sundry.range args-list);
  tests = {
    prefix-two = [(slice [2] "abc") "ab"];
    single-index = [(slice [1 2] "abc") "b"];
    step-two = [(slice [0 3 2] "abc") "ac"];
    reverse-all = [(slice [2 (-1) (-1)] "abc") "cba"];
    reverse-two = [(slice [1 (-2) (-1)] "abc") "bac"];
    out-of-bounds = [(slice [3 0] "abc") ""];
    empty-reverse = [(slice [0 3 (-1)] "abc") ""];
    empty-single = [(slice [1 1] "abc") ""];
    step-three = [(slice [0 5 3] "abcdefg") "ad"];
  };
}
