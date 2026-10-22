{lib, ...}: rec {
  insert-at = i: x: list:
    (lib.sublist 0 i list) ++ (lib.toList x) ++ (lib.sublist i (lib.length list) list);

  tests = {
    insert-at-start = [(insert-at 0 "A" ["B" "C"]) ["A" "B" "C"]];
    insert-at-middle = [(insert-at 1 "A" ["B" "C"]) ["B" "A" "C"]];
    insert-at-end = [(insert-at 2 "A" ["B" "C"]) ["B" "C" "A"]];
    insert-into-empty = [(insert-at 0 "A" []) ["A"]];
    insert-list-in-middle = [(insert-at 1 ["A" "B"] ["C" "D"]) ["C" "A" "B" "D"]];
    insert-empty-list = [(insert-at 0 [] ["A"]) ["A"]];
  };
}
