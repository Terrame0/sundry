{
  lib,
  utils,
  ...
}: rec {
  recurse = default: name: acc-value: value:
    if lib.isAttrs acc-value && lib.isAttrs value
    then utils.attrs.merge-with (next-name: recurse default "${name}.${next-name}") [acc-value value]
    else default acc-value value;
}
