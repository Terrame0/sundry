{
  lib,
  utils,
  ...
}: rec {
  filter = fn: attrs:
    utils.attrs.merge.recursive.no-collision
    (lib.mapAttrsToListRecursive (
        path: value:
          if fn path value
          then lib.setAttrByPath path value
          else {}
      )
      attrs);
  tests = [
    [
      (filter
        (path: value: lib.mod value 2 == 1)
        {
          a = {
            b = 3;
            c = 4;
            d = {e = 7;};
            f = 12;
          };
        })
      {
        a = {
          b = 3;
          d = {e = 7;};
        };
      }
    ]
  ];
}
