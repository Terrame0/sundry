{
  sundry,
  lib,
  ...
}: rec {
  apply-between = fn: lsep: rsep: str: let
    insides =
      lib.filter
      (entry: entry.depth == 1)
      (sundry.str.delimit lsep rsep str).inside;
    result =
      sundry.for
      [0 (i: i + 1) (i: i < (lib.length insides))]
      {
        inherit str;
        offset = 0;
      }
      (prev: i: let
        entry = sundry.list.at i insides;
        substring = entry.substr;
        replacement = fn substring;
      in {
        str =
          sundry.str.replace-at
          (entry.pos + prev.offset)
          (sundry.str.len entry.substr)
          replacement
          prev.str;
        offset = prev.offset + sundry.str.len replacement - sundry.str.len substring;
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
