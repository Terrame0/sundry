{lib, ...}: rec {
  walk-until = cond: fn: set: let
    recurse = path:
      lib.mapAttrs (
        name: value: let
          path' = path ++ [name];
        in
          if lib.isAttrs value && !(cond path' value)
          then recurse path' value
          else fn path' value
      );
  in
    recurse [] set;
  walk = lib.mapAttrsRecursive;
  tests = [
    [
      (walk-until (path: value: lib.length path > 1) (path: value: 1) {
        a = 2;
        b = {
          c = {d = 4;};
        };
      })
      {
        a = 1;
        b = {c = 1;};
      }
    ]
  ];
}
