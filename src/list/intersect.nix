{lib, ...}: rec {
  intersect = a: b:
    lib.intersectLists
    (lib.toList a)
    (lib.toList b);

  tests = {
    same-singletons = [(intersect "A" "A") ["A"]];
    different-singletons = [(intersect "A" "B") []];
    list-and-singleton = [(intersect ["A" "B"] "A") ["A"]];
    overlapping-lists = [(intersect ["A" "B"] ["B" "C"]) ["B"]];
    disjoint-lists = [(intersect ["A" "B"] ["C" "D"]) []];
    empty-second = [(intersect ["A" "B"] []) []];
    both-empty = [(intersect [] []) []];
  };
}
