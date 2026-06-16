{mlem, ...}: let
  find-nth-base = fn: init-offset: step: n: seq: str:
    if n == 0
    then null
    else
      (
        mlem.for [0 (i: i + 1) (i: i < n)]
        {offset = init-offset;}
        (prev: i: rec {
          offset = fn (step prev.offset) seq str;
          break = offset == null;
        })
      ).offset;
in rec {
  find-nth = n: seq: str:
    find-nth-base
    mlem.str.find-after
    (-1)
    (offset: offset + 1)
    n
    seq
    str;
  rfind-nth = n: seq: str:
    find-nth-base
    mlem.str.rfind-after
    (mlem.str.len str - mlem.str.len seq + 1)
    (offset: offset - 1)
    n
    seq
    str;
  tests = [
    [(find-nth 1 "a" "abab") 0]
    [(find-nth 2 "a" "abab") 2]
    [(find-nth 1 "ab" "ababab") 0]
    [(find-nth 2 "ab" "ababab") 2]
    [(find-nth 3 "a" "abab") null]
    [(find-nth 0 "a" "abab") null]

    [(rfind-nth 1 "a" "abab") 2]
    [(rfind-nth 2 "a" "abab") 0]
    [(rfind-nth 1 "ab" "ababab") 4]
    [(rfind-nth 2 "ab" "ababab") 2]
    [(rfind-nth 3 "a" "abab") null]
    [(rfind-nth 0 "a" "abab") null]
  ];
}
