{lib, ...}: rec {
  intersect = a: b:
    lib.intersectLists
    (lib.toList a)
    (lib.toList b);

  tests = [
    [(intersect "A" "A") ["A"]]
    [(intersect "A" "B") []]
    [(intersect ["A" "B"] "A") ["A"]]
    [(intersect ["A" "B"] ["B" "C"]) ["B"]]
    [(intersect ["A" "B"] ["C" "D"]) []]
    [(intersect ["A" "B"] []) []]
    [(intersect [] []) []]
  ];
}
