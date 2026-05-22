{
  utils,
  lib,
  ...
}: rec {
  replace-at = pos: len: replacement: str: let
    before = lib.substring 0 pos str;
    after = lib.substring (pos + len) (utils.string.len str) str;
  in
    before + replacement + after;
  tests = [
    [(replace-at 2 2 "..." "abcdef") "ab...ef"]
    [(replace-at 3 0 "." "abcdef") "abc.def"]
    [(replace-at 2 2 "" "abcdef") "abef"]
  ];
}
