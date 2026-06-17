{mlem, ...}: rec {
  base.no-conflict = name: lhs: rhs:
    if lhs != rhs
    then
      throw
      ''

        there is a conflict in attrset merge at '${name}'
          lhs:
            ${mlem.str.pretty lhs}
          rhs:
            ${mlem.str.pretty rhs}
      ''
    else rhs;
  tests = [
    [(builtins.tryEval (base.no-conflict "_" {A = 1;} {A = 2;})).success false]
    [(base.no-conflict "_" 1 1) 1]
    [
      (mlem.attrs.merge.no-conflict [
        {A = 1;}
        {
          A = 1;
          B = 2;
        }
      ])
      {
        A = 1;
        B = 2;
      }
    ]
  ];
}
