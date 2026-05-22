{
  lib,
  utils,
  ...
}: {
  merge-recursive = let
    merge-fn = name: acc-value: value:
      if lib.isAttrs acc-value && lib.isAttrs value
      then utils.attrs.merge-with (next-name: merge-fn "${name}.${next-name}") [acc-value value]
      else value;
  in
    utils.attrs.merge-with merge-fn;
}
