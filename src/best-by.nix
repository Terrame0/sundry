{lib, ...}: rec {
  best-by = pred: list: let
    labeled-list = lib.forEach list (list-entry: {
      key = lib.head list-entry;
      value = lib.last list-entry;
    });
    result =
      lib.foldl
      (
        result-acc: list-entry:
          if pred list-entry.key result-acc.key
          then list-entry
          else result-acc
      )
      (lib.head labeled-list)
      labeled-list;
  in
    result.value;

  tests = [
    [(best-by (l: r: l < r) [[1 "a"] [2 "b"] [3 "c"]]) "a"]
    [(best-by (l: r: l > r) [[1 "a"] [2 "b"] [3 "c"]]) "c"]
    [(best-by (l: r: l > r) [[1 "a"] [1 "b"]]) "a"]
    [(best-by (l: r: l >= r) [[1 "a"] [1 "b"]]) "b"]
  ];
}
