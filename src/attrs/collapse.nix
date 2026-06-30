{lib, ...}: rec {
  collapse-matched-until = matches: halt: fn: set:
    lib.pipe set [
      (lib.mapAttrsToListRecursiveCond
        (path: attrs: !(halt path attrs))
        (path: value:
          if matches path value
          then [(fn path value)]
          else []))
      lib.concatLists
    ];
  collapse-until = collapse-matched-until (path: value: true);
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
      (collapse-matched-until
        (path: value: value != 0)
        (path: value: lib.length path > 1)
        (path: value: path)
        attrs)
      [
        ["B"]
        ["C" "D"]
        ["E" "F"]
      ]
    ]
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
