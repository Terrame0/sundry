{
  lib,
  mlem,
  ...
}: let
  reform-base = base: fn: attrs:
    mlem.attrs.merge.recursive.no-collision
    (base (path: value: let
      result =
        mlem.attrs.validate
        (fn path value)
        {
          path = {
            check = value:
              lib.isList value
              && (lib.all (x: lib.isString x) value);
            desc = "the path is not a list of strings";
          };
          value = {};
          omit = {
            default = false;
            check = value: lib.isBool value;
            desc = "must be either 'true' or 'false'";
          };
        };
    in
      if !result.omit
      then lib.setAttrByPath result.path result.value
      else {})
    attrs);
in rec {
  reform-until = cond:
    reform-base
    (lib.mapAttrsToListRecursiveCond
      (path: value: !(cond path value)));
  reform = reform-base lib.mapAttrsToListRecursive;
  tests = [
    [
      (reform-until
        (path: value: value ? e)
        (path: value: {
          value = value;
          path = map (x: x + "-m") path;
          omit = lib.isInt value && value == 1;
        })
        {
          a = {
            b = 1;
            c = 2;
            d = {e = 3;};
          };
        })
      {
        a-m = {
          c-m = 2;
          d-m = {
            e = 3;
          };
        };
      }
    ]
  ];
}
