{mlem, ...}: rec {
  base.no-conflict = name: lhs: rhs:
    if lhs != rhs
    then
      throw
      ''

        there is a conflict in attrset merge at '${name}'
          lhs:
            ${mlem.string.pretty lhs}
          rhs:
            ${mlem.string.pretty rhs}
      ''
    else rhs;
  tests = [
    [(builtins.tryEval (base.no-conflict "_" {a = 1;} {a = 2;})).success false]
  ];
}
