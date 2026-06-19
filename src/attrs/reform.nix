{
  lib,
  sundry,
  ...
}: let
  reform-base = base: fn: attrs:
    sundry.attrs.merge.recursive.no-collision
    (base (path: value: let
      result =
        sundry.attrs.validate
        (fn path value)
        {
          path = {
            check = value:
              lib.isList value
              && (lib.all (x: lib.isString x) value);
            desc = "must be a list of strings";
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
    reform-base (sundry.attrs.collapse-until cond);
  reform = reform-base sundry.attrs.collapse;
  tests = [
    [
      (reform-until
        (path: value: value ? E)
        (path: value: {
          value = value;
          path = map (x: x + "-M") path;
          omit = lib.isInt value && value == 1;
        })
        {
          A = {
            B = 1;
            C = 2;
            D = {E = 3;};
          };
        })
      {
        A-M = {
          C-M = 2;
          D-M = {
            E = 3;
          };
        };
      }
    ]
    [
      (reform-until
        (path: value: !lib.isAttrs value)
        (path: value: {
          inherit path value;
          omit = true;
        })
        {
          A = 1;
          B = {C = 2;};
        })
      {}
    ]
    [
      (reform-until
        (path: value: !lib.isAttrs value)
        (path: value: {inherit path value;})
        {
          A = 1;
          B = {C = 2;};
        })
      {
        A = 1;
        B = {C = 2;};
      }
    ]
  ];
}
