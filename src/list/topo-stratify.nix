{lib, ...}: rec {
  topo-stratify = let
    levels = done: left:
      if left == []
      then []
      else let
        expose-names = entries:
          map (entry: entry.name) entries;
        current-level =
          lib.filter
          (entry:
            lib.all
            (dependency: lib.elem dependency done)
            (entry.deps or []))
          left;
      in
        if current-level != []
        then let
          level-entry-names = expose-names current-level;
          next-left = lib.filter (entry:
            !(lib.elem
              entry.name
              level-entry-names))
          left;
          next-done = done ++ level-entry-names;
        in
          [current-level] ++ levels next-done next-left
        else throw "unresolvable dependencies: ${lib.concatMapStringsSep ", " (x: x.name) left}";
  in
    levels [];

  tests = let
    A = {name = "A";};
    B = {
      name = "B";
      deps = ["A"];
    };
    C = {
      name = "C";
      deps = ["A"];
    };
    D = {
      name = "D";
      deps = ["B" "C"];
    };
    E = {
      name = "E";
      deps = ["A" "C"];
    };
    F = {
      name = "F";
      deps = ["D" "E"];
    };
    G = {name = "G";};
    H = {
      name = "H";
      deps = ["G" "F"];
    };
    I = {
      name = "I";
      deps = ["B"];
    };
  in [
    [(topo-stratify [A B C D]) [[A] [B C] [D]]]
    [(topo-stratify [A B I]) [[A] [B] [I]]]
    [(topo-stratify [A B C D E F G H]) [[A G] [B C] [D E] [F] [H]]]
    [(topo-stratify [D C B A]) [[A] [C B] [D]]]
    [(topo-stratify [A]) [[A]]]
    [(topo-stratify [A G]) [[A G]]]
    [
      (builtins.tryEval (topo-stratify [
        {
          name = "X";
          deps = ["Y"];
        }
        {
          name = "Y";
          deps = ["X"];
        }
      ])).success
      false
    ]
    [
      (builtins.tryEval (topo-stratify [
        {
          name = "X";
          deps = ["missing"];
        }
      ])).success
      false
    ]
  ];
}
