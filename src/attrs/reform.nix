{
  lib,
  sundry,
  ...
}: let
  validate-leaf = sundry.attrs.validate {
    path = {
      check = value:
        lib.all (sundry.apply [value]) [
          lib.isList
          (lib.all lib.isString)
        ];
      desc = "must be a list of strings";
    };
    value = {};
    omit = {
      default = _: false;
      check = value: lib.isBool value;
      desc = "must be either 'true' or 'false'";
    };
  };
in rec {
  reform-matched-until = matches: halt: fn: attrs:
    lib.pipe attrs [
      (sundry.attrs.collapse-until
        halt
        (path: value: let
          result' = fn path value;
          result = validate-leaf result';
        in
          if matches path value
          then
            if result.omit
            then {}
            else lib.setAttrByPath result.path result.value
          else lib.setAttrByPath path value))
      sundry.attrs.merge.recursive.no-collision
    ];

  reform-until = reform-matched-until (path: value: true);
  reform-matched = lib.flip reform-matched-until (path: value: false);
  reform = reform-until (path: value: false);

  tests = let
    attrs = {
      A = 0;
      B = 1;
      C = {D = 2;};
      E = {F = {G = 0;};};
    };
  in {
    matched-until = [
      (reform-matched-until
        (path: value: value != 0)
        (path: value: lib.length path > 1)
        (path: value: {
          path = [(sundry.str.join-with "." path)];
          value = "x";
        })
        attrs)
      {
        A = 0;
        B = "x";
        "C.D" = "x";
        "E.F" = "x";
      }
    ];
    matched-omit = [
      (reform-matched
        (path: value: value != 0)
        (path: value:
          if value == 1
          then {inherit path value;} // {omit = true;}
          else {inherit path value;})
        attrs)
      {
        A = 0;
        C = {D = 2;};
        E = {F = {G = 0;};};
      }
    ];
    zero-leaves-unchanged = [
      (reform-matched-until
        (path: value: value != 0)
        (path: value: false)
        (path: value:
          if value == 0
          then throw "fn called on non-matched leaf"
          else {inherit path value;})
        attrs)
      attrs
    ];
    until = [
      (reform-until
        (path: value: lib.length path > 1)
        (path: value: {
          path = [(sundry.str.join-with "." path)];
          value = "x";
        })
        attrs)
      {
        A = "x";
        B = "x";
        "C.D" = "x";
        "E.F" = "x";
      }
    ];
    all = [
      (reform
        (path: value: {
          path = [(sundry.str.join-with "." path)];
          value = "x";
        })
        attrs)
      {
        A = "x";
        B = "x";
        "C.D" = "x";
        "E.F.G" = "x";
      }
    ];
    rejects-string-path = [
      (sundry.does-throw (reform (path: value: {
          path = "A";
          value = "x";
        })
        attrs))
      true
    ];
    rejects-non-string-path = [
      (sundry.does-throw (reform (path: value: {
          path = [1];
          value = "x";
        })
        attrs))
      true
    ];
    requires-value = [
      (sundry.does-throw (reform (path: value: {path = [(lib.last path)];}) attrs))
      true
    ];
    rejects-non-bool-omit = [
      (sundry.does-throw (reform (path: value: {
          path = [(lib.last path)];
          value = "x";
          omit = "no";
        })
        attrs))
      true
    ];
    rejects-extra-field = [
      (sundry.does-throw (reform (path: value: {
          path = [(lib.last path)];
          value = "x";
          junk = 1;
        })
        attrs))
      true
    ];
    throws-on-collision = [
      (sundry.does-throw (reform (path: value: {
          path = ["A"];
          value = "x";
        })
        {
          A = 1;
          B = 2;
        }))
      true
    ];
  };
}
