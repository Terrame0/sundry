{lib, ...}: rec {
  product = lhs: rhs:
    lib.concatLists
    (map (lhs-entry:
      map (rhs-entry: [lhs-entry rhs-entry])
      rhs)
    lhs);
  tests = {
    non-empty-lists = [
      (product [1 2 3] [4 5])
      [[1 4] [1 5] [2 4] [2 5] [3 4] [3 5]]
    ];
    empty-lhs = [(product [] [1 2]) []];
    single-elements = [(product [1] [2]) [[1 2]]];
  };
}
