{
  lib,
  utils,
  ...
}: let
  find-after-base = step: init-id: seq: str: let
    result =
      utils.for [init-id step (i: true)]
      {pos = null;}
      (prev: i: let
        str-len = utils.string.len str;
        seq-len = utils.string.len seq;
        within-bounds = 0 <= i && i <= (str-len - seq-len);
      in {
        pos =
          if within-bounds
          then i
          else null;
        break =
          !within-bounds
          || (lib.substring i seq-len str == seq);
      });
  in
    result.pos;
in rec {
  find-after = find-after-base (i: i + 1);
  rfind-after = find-after-base (i: i - 1);
  tests = [
    [(find-after 0 "a" "abc") 0]
    [(find-after 0 "b" "abc") 1]
    [(find-after 0 "c" "abc") 2]
    [(find-after 0 "d" "abc") null]
    [(find-after 0 "ab" "abab") 0]
    [(find-after 1 "ab" "abab") 2]
    [(find-after 0 "" "ababab") 0]
    [(find-after 0 "abcd" "abc") null]
    [(find-after 0 "abc" "") null]
    [(rfind-after 2 "a" "abc") 0]
    [(rfind-after 2 "b" "abc") 1]
    [(rfind-after 2 "c" "abc") 2]
    [(rfind-after 2 "d" "abc") null]
    [(rfind-after 1 "ab" "abab") 0]
    [(rfind-after 2 "ab" "abab") 2]
    [(rfind-after 2 "" "ababab") 2]
    [(rfind-after 2 "abcd" "abc") null]
    [(rfind-after 2 "abc" "") null]
  ];
}
