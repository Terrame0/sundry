{
  lib,
  mlem,
  ...
}: let
  reform-base = base: fn: attrs:
    mlem.attrs.merge.recursive.no-collision
    (base (
        path: value: let
          result =
            mlem.validate.attrs
            (fn path value)
            {
              path = arg: {
                check =
                  lib.isList arg
                  && (lib.all (x: lib.isString x) arg);
                error-msg = "the path is not a list of strings";
              };
              value = _: {};
              omit = _: {default = false;};
            };
        in
          if !result.omit
          then lib.setAttrByPath result.path result.value
          else {}
      )
      attrs);
in rec {
  reform-cond = cond: reform-base (lib.mapAttrsToListRecursiveCond cond);
  reform = reform-base lib.mapAttrsToListRecursive;
  tests = [
    [
      (reform-cond (path: value: !(value ? e))
        (path: value: {
          value = value;
          path = map (x: x + "-m") path;
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
          b-m = 1;
          c-m = 2;
          d-m = {
            e = 3;
          };
        };
      }
    ]
  ];
}
