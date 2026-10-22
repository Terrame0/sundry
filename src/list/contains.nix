{lib, ...}: rec {
  contains = super: sub:
    lib.subtractLists
    (lib.toList super)
    (lib.toList sub)
    == [];

  tests = {
    same-value = [(contains "A" "A") true];
    different-values = [(contains "A" "B") false];
    list-contains-string = [(contains ["A" "B"] "A") true];
    string-cannot-contain-list = [(contains "A" ["A" "B"]) false];
    list-contains-sublist = [(contains ["A" "B" "C"] ["A" "B"]) true];
    list-does-not-contain-sublist = [(contains ["A" "B"] ["A" "B" "C"]) false];
    empty-sublist = [(contains ["A" "B"] []) true];
    empty-super = [(contains [] ["A"]) false];
    both-empty = [(contains [] []) true];
  };
}
