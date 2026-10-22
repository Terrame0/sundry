{lib, ...}: rec {
  remove-at = i: list:
    (lib.sublist 0 i list) ++ (lib.sublist (i + 1) (lib.length list) list);

  tests = {
    first = [(remove-at 0 ["A" "B" "C"]) ["B" "C"]];
    middle = [(remove-at 1 ["A" "B" "C"]) ["A" "C"]];
    last = [(remove-at 2 ["A" "B" "C"]) ["A" "B"]];
    single-element = [(remove-at 0 ["A"]) []];
  };
}
