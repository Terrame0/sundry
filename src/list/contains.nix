{lib, ...}: rec {
  contains = sub: super:
    lib.subtractLists
    (lib.toList super)
    (lib.toList sub)
    == [];

  tests = [
    [(contains "A" "A") true]
    [(contains "B" "A") false]
    [(contains "A" ["A" "B"]) true]
    [(contains ["A" "B"] "A") false]
    [(contains ["A" "B"] ["A" "B" "C"]) true]
    [(contains ["A" "B" "C"] ["A" "B"]) false]
    [(contains [] ["A" "B"]) true]
    [(contains ["A"] []) false]
    [(contains [] []) true]
  ];
}
