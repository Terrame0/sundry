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
    [(best-by (l: r: l < r) [[1 "A"] [2 "B"] [3 "C"]]) "A"]
    [(best-by (l: r: l > r) [[1 "A"] [2 "B"] [3 "C"]]) "C"]
    [(best-by (l: r: l > r) [[1 "A"] [1 "B"]]) "A"]
    [(best-by (l: r: l >= r) [[1 "A"] [1 "B"]]) "B"]
  ];
}
