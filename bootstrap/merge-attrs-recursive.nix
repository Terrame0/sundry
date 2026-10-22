{
  lib,
  bootstrap,
  ...
}:
bootstrap.merge-attrs (lib.fix (self: path: acc-value: value:
    if lib.isAttrs acc-value && lib.isAttrs value
    then bootstrap.merge-attrs (next-path: self (path ++ next-path)) acc-value value
    else throw "there is a collision at '${lib.concatStringsSep "." path}'"))
