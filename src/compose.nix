{lib, ...}: rec {
  compose = fns:
    lib.foldr
    (f: f)
    (lib.last fns)
    (lib.init fns);

  tests = {
    single-function = [(compose [(x: x + 1)] 3) 4];
    identity = [(compose [lib.id (x: x + 1)] 3) 4];
    two-functions = [(compose [(next: x: next (x * 2)) (x: x + 1)] 3) 7];
  };
}
