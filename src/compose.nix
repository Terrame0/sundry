{lib, ...}: rec {
  compose = fns:
    lib.foldr
    (f: f)
    (lib.last fns)
    (lib.init fns);

  tests = [
    [(compose [(x: x + 1)] 3) 4]
    [(compose [lib.id (x: x + 1)] 3) 4]
    [(compose [(next: x: next (x * 2)) (x: x + 1)] 3) 7]
  ];
}
