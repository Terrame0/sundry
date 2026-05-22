{
  lib,
  utils,
  ...
}: rec {
  merge-recursive-with = default: let
    merge-fn-rec = name: acc-value: value:
      if lib.isAttrs acc-value && lib.isAttrs value
      then utils.attrs.merge-with (next-name: merge-fn-rec "${name}.${next-name}") [acc-value value]
      else default acc-value value;
  in
    utils.attrs.merge-with merge-fn-rec;
  tests = [
    [
      (merge-recursive-with (lhs: rhs: rhs) [
        {
          a = {b = {c = 1;};};
        }
        {
          a = {b = {c = 2;};};
        }
      ])
      {
        a = {b = {c = 2;};};
      }
    ]
  ];
}
