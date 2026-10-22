{
  lib,
  sundry,
  ...
}: rec {
  permutations = k: list: let
    list-len = lib.length list;
    recurse = left: result:
      if (lib.length left) < (list-len - k + 1)
      then [result]
      else
        lib.concatLists (map (i:
          recurse
          (sundry.list.remove-at i left)
          (result ++ [(sundry.list.at i left)]))
        (sundry.range [(lib.length left)]));
  in
    if k >= 0 && k <= list-len
    then recurse list []
    else throw "k has to be between 0 and ${toString list-len}, but k is ${toString k}";
  tests = {
    k-equals-length = [
      (permutations 3 [1 2 3])
      [[1 2 3] [1 3 2] [2 1 3] [2 3 1] [3 1 2] [3 2 1]]
    ];
    k-two = [
      (permutations 2 [1 2 3])
      [[1 2] [1 3] [2 1] [2 3] [3 1] [3 2]]
    ];
    k-one = [
      (permutations 1 [1 2 3])
      [[1] [2] [3]]
    ];
    k-zero = [
      (permutations 0 [1 2 3])
      [[]]
    ];
    k-zero-empty-list = [(permutations 0 []) [[]]];
    k-exceeds-length-throws = [(sundry.does-throw (permutations 3 [1 2])) true];
  };
}
