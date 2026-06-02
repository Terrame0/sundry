{...}: rec {
  base.no-collision = name: lhs: rhs:
    throw "\nthere is a collision in attrset merge at '${name}'";
  tests = [
    [(builtins.tryEval (base.no-collision "_" {a = 1;} {a = 1;})).success false]
  ];
}
