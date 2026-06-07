{
  lib,
  mlem,
  ...
}: rec {
  validate = attrs: template: let
    fmt-leaves = lib.mapAttrsRecursive (_: value: "(...)");

    fmt = value:
      mlem.string.apply-to-lines
      (line: "  ${line}")
      (mlem.string.pretty value);
    comparison = mlem.attrs.compare attrs template;

    defaults =
      lib.mapAttrsRecursive
      (_: fn: let spec = fn spec.default; in [spec.default fn])
      (mlem.attrs.filter
        # -- enforces that 'default' is non self-referential
        (_: fn: (lib.fix (self: fn self.default)) ? default)
        comparison.missing);

    with-defaults =
      mlem.attrs.merge.recursive.no-collision
      [comparison.matched defaults];

    passed-tests =
      mlem.attrs.merge.recursive.no-collision
      (lib.mapAttrsToListRecursive (
          path: pair: let
            value = mlem.list.at 0 pair;
            validator = mlem.list.at 1 pair;
            spec = validator value;
            passed =
              if spec.nullable or false && value == null
              then true
              else if !(spec ? check)
              then true
              else if !(spec ? error-msg)
              then throw "attribute spec that has a 'check' attribute must also have an 'error-msg' attribute"
              else assert builtins.isBool spec.check; spec.check;
          in
            if passed
            then lib.setAttrByPath path (mlem.list.at 0 pair)
            else {}
        )
        with-defaults);
  in
    lib.foldl mlem.check-success passed-tests [
      # -- unexpected attributes check
      {
        success = comparison.extra == {};
        error-msg = "got unexpected attributes:\n${fmt comparison.extra}";
      }
      # -- missing attributes check
      (let
        result = mlem.attrs.compare defaults comparison.missing;
      in {
        success = result.missing == {};
        error-msg = "missing attributes:\n${fmt (fmt-leaves result.missing)}";
      })
      # -- passed tests check
      (let
        result = mlem.attrs.compare passed-tests with-defaults;
        resolved-str = lib.pipe result.missing [
          (lib.mapAttrsToListRecursive
            (path: pair: let
              value = mlem.list.at 0 pair;
              validator = mlem.list.at 1 pair;
            in "  ${lib.concatStringsSep "." path}: ${(validator value).error-msg}"))
          (lib.concatStringsSep "\n")
        ];
      in {
        success = result.missing == {};
        error-msg = "incorrect attribute values:\n${resolved-str}";
      })
    ];

  tests = [
    [
      (
        validate
        {a = 2;}
        {
          a = value: {
            default = 2;
            check = lib.mod value 2 == 0;
            error-msg = "${toString value} is not divisible by 2";
          };
          b = value: {
            default = null;
            nullable = true;
            check = lib.mod value 3 == 0;
            error-msg = "${toString value} is not divisible by 3";
          };
          c = {d = value: {default = 4;};};
        }
      )
      {
        a = 2;
        b = null;
        c = {d = 4;};
      }
    ]
    [
      (builtins.tryEval (
        validate
        {a = 1;}
        {
          a = value: {};
          b = value: {};
        }
      )).success
      false
    ]
    [
      (builtins.tryEval (
        validate
        {a = 1;}
        {
          a = value: {
            default = 2;
            check = lib.mod value 2 == 0;
            error-msg = "${toString value} is not divisible by 2";
          };
        }
      )).success
      false
    ]
  ];
}
