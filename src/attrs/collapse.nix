{lib, ...}: {
  collapse = lib.mapAttrsToListRecursive;
  collapse-until = cond:
    lib.mapAttrsToListRecursiveCond
    (path: value: !(cond path value));
}
