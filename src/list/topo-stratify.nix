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
            (entry.depends-on or []))
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
      depends-on = ["A"];
    };
    C = {
      name = "C";
      depends-on = ["A"];
    };
    D = {
      name = "D";
      depends-on = ["B" "C"];
    };
    E = {
      name = "E";
      depends-on = ["A" "C"];
    };
    F = {
      name = "F";
      depends-on = ["D" "E"];
    };
    G = {name = "G";};
    H = {
      name = "H";
      depends-on = ["G" "F"];
    };
    I = {
      name = "I";
      depends-on = ["B"];
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
          depends-on = ["Y"];
        }
        {
          name = "Y";
          depends-on = ["X"];
        }
      ])).success
      false
    ]
    [
      (builtins.tryEval (topo-stratify [
        {
          name = "X";
          depends-on = ["missing"];
        }
      ])).success
      false
    ]
  ];
}
