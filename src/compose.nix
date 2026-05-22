{lib, ...}: {
  compose = fns:
    lib.foldr
    (f: acc: f acc)
    (lib.last fns)
    (lib.init fns);
}
