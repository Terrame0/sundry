{lib, ...}: rec {
  is-in = requirements: value:
    lib.any (allowed-value: value == allowed-value) requirements;

  tests = [
    [(is-in ["a" "b" "c"] "a") true]
    [(is-in ["b" "c" "d"] "a") false]
  ];
}
