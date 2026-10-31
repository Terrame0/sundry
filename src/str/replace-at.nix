{
  sundry,
  lib,
  ...
}: rec {
  replace-at = pos: len: replacement: str: let
    before = lib.substring 0 pos str;
    after = lib.substring (pos + len) (sundry.str.len str) str;
  in
    before + replacement + after;

  tests = {
    replace-middle = [(replace-at 2 2 "..." "ABCDEF") "AB...EF"];
    insert-middle = [(replace-at 3 0 "." "ABCDEF") "ABC.DEF"];
    delete-middle = [(replace-at 2 2 "" "ABCDEF") "ABEF"];
    insert-at-start = [(replace-at 0 0 "X" "ABC") "XABC"];
    insert-at-end = [(replace-at 6 0 "X" "ABCDEF") "ABCDEFX"];
  };
}
