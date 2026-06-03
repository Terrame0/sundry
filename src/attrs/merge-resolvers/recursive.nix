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
      (mlem.attrs.merge.recursive.override [{a = {b = 1;};} {a = {b = 2;};}])
      {a = {b = 2;};}
    ]
  ];
}
