{
  utils,
  lib,
  ...
}: rec {
  apply-between = fn: lsep: rsep: str: let
    insides =
      lib.filter
      (entry: entry.depth == 1)
      (utils.string.delimit lsep rsep str).inside;
    result =
      utils.for
      [0 (i: i + 1) (i: i < (lib.length insides))]
      {
        inherit str;
        offset = 0;
      }
      (prev: i: let
        entry = utils.list.at i insides;
        substring = entry.substr;
        replacement = fn substring;
      in {
        str =
          utils.string.replace-at
          (entry.pos + prev.offset)
          (utils.string.len entry.substr)
          replacement
          prev.str;
        offset = prev.offset + utils.string.len replacement - utils.string.len substring;
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
