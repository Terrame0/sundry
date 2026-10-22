{
  lib,
  sundry,
  ...
}: let
  find-after-base = step: init-id: seq: str: let
    result =
      sundry.for [init-id sundry.true-fn step]
      {pos = null;}
      (prev: i: let
        str-len = sundry.str.len str;
        seq-len = sundry.str.len seq;
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
  tests = {
    finds-at-start = [(find-after 0 "A" "ABC") 0];
    finds-in-middle = [(find-after 0 "B" "ABC") 1];
    finds-at-end = [(find-after 0 "C" "ABC") 2];
    missing = [(find-after 0 "D" "ABC") null];
    finds-first-occurrence = [(find-after 0 "AB" "ABAB") 0];
    skips-first-occurrence = [(find-after 1 "AB" "ABAB") 2];
    empty-needle = [(find-after 0 "" "ABABAB") 0];
    needle-longer-than-haystack = [(find-after 0 "ABCD" "ABC") null];
    empty-haystack = [(find-after 0 "ABC" "") null];
    rfind-at-start = [(rfind-after 2 "A" "ABC") 0];
    rfind-in-middle = [(rfind-after 2 "B" "ABC") 1];
    rfind-at-end = [(rfind-after 2 "C" "ABC") 2];
    rfind-missing = [(rfind-after 2 "D" "ABC") null];
    rfind-finds-first-occurrence = [(rfind-after 1 "AB" "ABAB") 0];
    rfind-finds-last-occurrence = [(rfind-after 2 "AB" "ABAB") 2];
    rfind-empty-needle = [(rfind-after 2 "" "ABABAB") 2];
    rfind-needle-longer-than-haystack = [(rfind-after 2 "ABCD" "ABC") null];
    rfind-empty-haystack = [(rfind-after 2 "ABC" "") null];
  };
}
