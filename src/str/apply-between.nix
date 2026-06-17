{
  mlem,
  lib,
  ...
}: rec {
  apply-between = fn: lsep: rsep: str: let
    insides =
      lib.filter
      (entry: entry.depth == 1)
      (mlem.str.delimit lsep rsep str).inside;
    result =
      mlem.for
      [0 (i: i + 1) (i: i < (lib.length insides))]
      {
        inherit str;
        offset = 0;
      }
      (prev: i: let
        entry = mlem.list.at i insides;
        substring = entry.substr;
        replacement = fn substring;
      in {
        str =
          mlem.str.replace-at
          (entry.pos + prev.offset)
          (mlem.str.len entry.substr)
          replacement
          prev.str;
        offset = prev.offset + mlem.str.len replacement - mlem.str.len substring;
      });
  in
    result.str;

  tests = [
    [
      (apply-between (str: "${str}-changed") "[" "]" "A[X]B[Y]C[Z]D")
      "A[X-changed]B[Y-changed]C[Z-changed]D"
    ]
    [
      (apply-between (str: "-") "[" "]" "[[][]][]")
      "[-][-]"
    ]
    [(apply-between (str: "X") "[" "]" "ABC") "ABC"]
  ];
}
