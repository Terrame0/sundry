{lib, ...}: rec {
  is-in = requirements: value:
    if builtins.isList requirements
    then lib.any (r: value == r) requirements
    else requirements == value;

  tests = [
    [(is-in "a" "a") true]
    [(is-in "b" "a") false]
    [(is-in ["a" "b" "c"] "a") true]
    [(is-in ["b" "c" "d"] "a") false]
  ];
}
