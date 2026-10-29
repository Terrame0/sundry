{
  lib,
  sundry,
  ...
}: let
  # -- '' and '.' and '..' name the wrong directory once joined, and '/'
  # - would split one segment into two in the shell path
  is-invalid = segment:
    segment
    == ""
    || segment == "."
    || segment == ".."
    || lib.hasInfix "/" segment;
in rec {
  validate = path: let
    invalid = lib.findFirst is-invalid null path;
  in
    if invalid == null
    then path
    else throw "invalid vfs path segment '${invalid}' in ${sundry.str.pretty path}";

  tests = {
    valid-path = [(validate ["A" "B.txt"]) ["A" "B.txt"]];
    empty-path = [(validate []) []];
    dots-in-name = [(validate ["A.txt" "..B" "B."]) ["A.txt" "..B" "B."]];
    ellipsis = [(validate ["..."]) ["..."]];
    throws-on-empty-segment = [(sundry.does-throw (validate ["A" "" "B"])) true];
    throws-on-dot = [(sundry.does-throw (validate ["A" "."])) true];
    throws-on-dot-dot = [(sundry.does-throw (validate ["A" ".." "B"])) true];
    throws-on-slash = [(sundry.does-throw (validate ["A" "B/C"])) true];
  };
}
