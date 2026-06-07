{
  mlem,
  lib,
  ...
}: {
  base.concat = name: lhs: rhs:
    lib.toList lhs ++ lib.toList rhs;
  tests = [
    [
      (mlem.attrs.merge.concat [{a = [1 2];} {a = 3;}])
      {a = [1 2 3];}
    ]
  ];
}
