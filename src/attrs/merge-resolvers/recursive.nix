{
  lib,
  mlem,
  ...
}: rec {
  recursive = default: name: acc-value: value:
    if lib.isAttrs acc-value && lib.isAttrs value
    then mlem.attrs.merge-with (next-name: recursive default "${name}.${next-name}") [acc-value value]
    else default name acc-value value;
  tests = [
    [
      (mlem.attrs.merge.recursive.override [{A = {B = 1;};} {A = {B = 2;};}])
      {A = {B = 2;};}
    ]
    [
      (mlem.attrs.merge.recursive.override [{A = {B = 1;};} {A = {C = 2;};}])
      {
        A = {
          B = 1;
          C = 2;
        };
      }
    ]
  ];
}
