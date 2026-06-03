{
  mlem,
  lib,
  ...
}: rec {
  apply-between = fn: lsep: rsep: str: let
    insides =
      lib.filter
      (entry: entry.depth == 1)
      (mlem.string.delimit lsep rsep str).inside;
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
          mlem.string.replace-at
          (entry.pos + prev.offset)
          (mlem.string.len entry.substr)
          replacement
          prev.str;
        offset = prev.offset + mlem.string.len replacement - mlem.string.len substring;
      });
  in
    result.str;

  tests = [
    [
      (apply-between (str: "${str}-changed") "[" "]" "a[x]b[y]c[z]d")
      "a[x-changed]b[y-changed]c[z-changed]d"
    ]
    [
      (apply-between (str: "-") "[" "]" "[[][]][]")
      "[-][-]"
    ]
  ];
}
