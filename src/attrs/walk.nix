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
        A = 2;
        B = {
          C = {D = 4;};
        };
      })
      {
        A = 1;
        B = {C = 1;};
      }
    ]
    [(walk-until (path: value: true) (path: value: "X") {}) {}]
    [
      (walk-until (path: value: true) (path: value: "X") {
        A = {B = 1;};
        C = 2;
      })
      {
        A = "X";
        C = "X";
      }
    ]
  ];
}
