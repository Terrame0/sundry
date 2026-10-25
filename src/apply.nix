{lib, ...}: rec {
  apply-n = arg: map (apply arg);
  apply = args': fn: let
    args = lib.toList args';
  in
    lib.foldl (f: x: f x) fn args;

  tests = {
    single-fn = [(apply 0 (x: x + 1)) 1];
    multiple-application = [(apply [4 2] (x: y: x / y)) 2];
    multiple-fns = [(apply-n 0 [lib.id (x: x + 1) (x: x + 2)]) [0 1 2]];
    predicate-combinator = [(lib.all (apply 1) [lib.isInt (x: x == 1)]) true];
  };
}
