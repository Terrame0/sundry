{
  lib,
  sundry,
  ...
}: rec {
  topo-stratify = let
    levels = done: left:
      if left == []
      then []
      else let
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
          level-entry-names = map (entry: entry.name) current-level;
          next-left = lib.filter (entry: !(lib.elem entry.name level-entry-names)) left;
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
  in {
    diamond = [(topo-stratify [A B C D]) [[A] [B C] [D]]];
    linear-chain = [(topo-stratify [A B I]) [[A] [B] [I]]];
    complex-graph = [(topo-stratify [A B C D E F G H]) [[A G] [B C] [D E] [F] [H]]];
    reversed-input = [(topo-stratify [D C B A]) [[A] [C B] [D]]];
    single-node = [(topo-stratify [A]) [[A]]];
    independent-nodes = [(topo-stratify [A G]) [[A G]]];
    cycle-throws = [
      (sundry.does-throw (topo-stratify [
        {
          name = "X";
          deps = ["Y"];
        }
        {
          name = "Y";
          deps = ["X"];
        }
      ]))
      true
    ];
    missing-dependency-throws = [
      (sundry.does-throw (topo-stratify [
        {
          name = "X";
          deps = ["missing"];
        }
      ]))
      true
    ];
  };
}
