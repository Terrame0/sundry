{lib, ...}: rec {
  contains = super: sub:
    lib.subtractLists
    (lib.toList super)
    (lib.toList sub)
    == [];

  tests = [
    [(contains "A" "A") true]
    [(contains "A" "B") false]
    [(contains ["A" "B"] "A") true]
    [(contains "A" ["A" "B"]) false]
    [(contains ["A" "B" "C"] ["A" "B"]) true]
    [(contains ["A" "B"] ["A" "B" "C"]) false]
    [(contains ["A" "B"] []) true]
    [(contains [] ["A"]) false]
    [(contains [] []) true]
  ];
}
