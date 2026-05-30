{
  lib,
  utils,
  ...
}: rec {
  permutations = list: k: let
    list-len = lib.length list;
    recurse = left: result:
      if (lib.length left) < (list-len - k + 1)
      then [result]
      else
        lib.concatLists (map (i:
          recurse
          (utils.list.remove-at i left)
          (result ++ [(utils.list.at i left)]))
        (lib.genList lib.id (lib.length left)));
  in
    if k >= 0 && k <= list-len
    then recurse list []
    else throw "k has to be between 0 and ${toString list-len}, but k is ${toString k}";
  tests = [
    [
      (permutations [1 2 3] 3)
      [[1 2 3] [1 3 2] [2 1 3] [2 3 1] [3 1 2] [3 2 1]]
    ]
    [
      (permutations [1 2 3] 2)
      [[1 2] [1 3] [2 1] [2 3] [3 1] [3 2]]
    ]
    [
      (permutations [1 2 3] 1)
      [[1] [2] [3]]
    ]
    [
      (permutations [1 2 3] 0)
      [[]]
    ]
  ];
}
