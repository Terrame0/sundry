{lib, ...}: rec {
  is-in = requirements: value:
    if builtins.isList requirements
    then lib.any (r: value == r) requirements
    else requirements == value;

  tests = [
    [(is-in "A" "A") true]
    [(is-in "B" "A") false]
    [(is-in ["A" "B" "C"] "A") true]
    [(is-in ["B" "C" "D"] "A") false]
    [(is-in [] "X") false]
  ];
}
