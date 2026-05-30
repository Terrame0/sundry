{
  lib,
  utils,
  ...
}: rec {
  recursive = default: name: acc-value: value:
    if lib.isAttrs acc-value && lib.isAttrs value
    then utils.attrs.merge-with (next-name: recursive default "${name}.${next-name}") [acc-value value]
    else default name acc-value value;
  tests = [
    [
      (utils.attrs.merge.recursive.override [{a = {b = 1;};} {a = {b = 2;};}])
      {a = {b = 2;};}
    ]
  ];
}
