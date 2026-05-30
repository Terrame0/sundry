{
  lib,
  utils,
  ...
}: rec {
  reform = fn: attrs:
    utils.attrs.merge.recursive.no-override
    (lib.mapAttrsToListRecursive (
        path: value: let
          result =
            utils.validate.attrs
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
  tests = [
    [
      (reform
        (path: value: {
          value = value + 1;
          path = map (x: x + "-new") path;
        })
        {
          a = {
            b = 10;
            c = 2;
            g = {c = 10;};
          };
        })
      {
        a-new = {
          b-new = 11;
          c-new = 3;
          g-new = {
            c-new = 11;
          };
        };
      }
    ]
  ];
}
