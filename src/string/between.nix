{
  utils,
  lib,
  ...
}: rec {
  between = lsep: rsep: str: let
    insides =
      lib.filter
      (entry: entry.depth == 1)
      (utils.string.delimit lsep rsep str).inside;
  in
    map (attrs: attrs.substr) insides;
  tests = [
    [
      (between "[" "]" "[abc[def]][ghi]")
      ["abc[def]" "ghi"]
    ]
  ];
}
