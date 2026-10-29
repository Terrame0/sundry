{lib, ...}: rec {
  insert-at = i: x: list:
    (lib.sublist 0 i list) ++ (lib.toList x) ++ (lib.sublist i (lib.length list) list);

  tests = {
    start = [(insert-at 0 "A" ["B" "C"]) ["A" "B" "C"]];
    middle = [(insert-at 1 "A" ["B" "C"]) ["B" "A" "C"]];
    end = [(insert-at 2 "A" ["B" "C"]) ["B" "C" "A"]];
    into-empty = [(insert-at 0 "A" []) ["A"]];
    list-in-middle = [(insert-at 1 ["A" "B"] ["C" "D"]) ["C" "A" "B" "D"]];
    empty-list = [(insert-at 0 [] ["A"]) ["A"]];
  };
}
