{
  mlem,
  lib,
  ...
}: {
  concat-lists = default: name: lhs: rhs:
    if lib.isList lhs && lib.isList rhs
    then lhs ++ rhs
    else default name lhs rhs;
  tests = [
    [
      (mlem.attrs.merge.concat-lists.override [{a = [1 2];} {a = [3];}])
      {a = [1 2 3];}
    ]
  ];
}
