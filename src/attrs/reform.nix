{
  lib,
  sundry,
  ...
}: let
  validate-leaf = sundry.attrs.validate {
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
in rec {
  reform-matched-until = does-match: do-recurse: fn: attrs:
    lib.pipe attrs [
      (sundry.attrs.collapse-matched-until
        does-match
        do-recurse
        (path: value: let
          result = validate-leaf (fn path value);
        in
          if !result.omit
          then lib.setAttrByPath result.path result.value
          else {}))
      sundry.attrs.merge.recursive.no-collision
    ];

  reform-until = reform-matched-until (path: value: true);
  reform = reform-until (path: value: false);
  tests = let
    attrs = {
      A = 0;
      B = 1;
      C = {D = 2;};
      E = {F = {G = 0;};};
    };
  in [
    [
      (reform-matched-until
        (path: value: value != 0)
        (path: value: lib.length path > 1)
        (path: value: {
          path = [(lib.concatStringsSep "." path)];
          inherit value;
        })
        attrs)
      {
        B = 1;
        "C.D" = 2;
        "E.F" = {G = 0;};
      }
    ]
    [
      (reform-until
        (path: value: lib.length path > 1)
        (path: value: {
          path = [(lib.concatStringsSep "." path)];
          inherit value;
        })
        attrs)
      {
        A = 0;
        B = 1;
        "C.D" = 2;
        "E.F" = {G = 0;};
      }
    ]
    [
      (reform
        (path: value: {
          path = [(lib.concatStringsSep "." path)];
          inherit value;
        })
        attrs)
      {
        A = 0;
        B = 1;
        "C.D" = 2;
        "E.F.G" = 0;
      }
    ]
  ];
}
