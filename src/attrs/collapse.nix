{lib, ...}: rec {
  collapse-until = halt: fn: set:
    lib.pipe set [
      (lib.mapAttrsToListRecursiveCond
        (path: value: !(halt path value))
        (path: value: [(fn path value)]))
      lib.concatLists
    ];
  collapse = collapse-until (path: value: false);

  tests = let
    attrs = {
      A = 0;
      B = 1;
      C = {D = 2;};
      E = {F = {G = 0;};};
    };
  in [
    [
      (collapse-until
        (path: value: lib.length path > 1)
        (path: value: path)
        attrs)
      [
        ["A"]
        ["B"]
        ["C" "D"]
        ["E" "F"]
      ]
    ]
    [
      (collapse
        (path: value: path)
        attrs)
      [
        ["A"]
        ["B"]
        ["C" "D"]
        ["E" "F" "G"]
      ]
    ]
  ];
}
