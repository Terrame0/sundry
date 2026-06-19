{
  sundry,
  lib,
  ...
}: rec {
  between = lsep: rsep: str: let
    insides =
      lib.filter
      (entry: entry.depth == 1)
      (sundry.str.delimit lsep rsep str).inside;
  in
    map (attrs: attrs.substr) insides;
  tests = [
    [
      (between "[" "]" "[ABC[DEF]][GHI]")
      ["ABC[DEF]" "GHI"]
    ]
    [(between "[" "]" "ABC") []]
    [(between "[" "]" "") []]
  ];
}
