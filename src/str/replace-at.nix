{
  mlem,
  lib,
  ...
}: rec {
  replace-at = pos: len: replacement: str: let
    before = lib.substring 0 pos str;
    after = lib.substring (pos + len) (mlem.str.len str) str;
  in
    before + replacement + after;
  tests = [
    [(replace-at 2 2 "..." "ABCDEF") "AB...EF"]
    [(replace-at 3 0 "." "ABCDEF") "ABC.DEF"]
    [(replace-at 2 2 "" "ABCDEF") "ABEF"]
    [(replace-at 0 0 "X" "ABC") "XABC"]
    [(replace-at 6 0 "X" "ABCDEF") "ABCDEFX"]
  ];
}
