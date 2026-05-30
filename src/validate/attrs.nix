{
  lib,
  utils,
  ...
}: rec {
  attrs = attrs: template: let
    fmt-leaves = lib.mapAttrsRecursive (_: value: "(...)");
    eval-pair = pair:
      (utils.list.at 1 pair)
      (utils.list.at 0 pair);

    fmt = value:
      utils.string.apply-to-lines
      (line: "  ${line}")
      (utils.string.pretty value);
    comparison = utils.attrs.compare attrs template;

    defaults =
      lib.mapAttrsRecursive
      (_: fn: let spec = fn spec.default; in [spec.default fn])
      (utils.attrs.filter
        # -- enforces that 'default' is non self-referential
        (_: fn: (lib.fix (self: fn self.default)) ? default)
        comparison.missing);

    with-defaults =
      utils.attrs.merge.recursive.no-override
      [comparison.matched defaults];

    passed-tests =
      utils.attrs.merge.recursive.no-override
      (lib.mapAttrsToListRecursive (
          path: pair: let
            spec = eval-pair pair;
            passed =
              if spec ? check
              then
                if spec ? error-msg
                then
                  assert builtins.isBool spec.check;
                    spec.check
                else throw "attribute spec that has the 'check' attribute must also have the 'error-msg' attribute"
              else true;
          in
            if passed
            then lib.setAttrByPath path (utils.list.at 0 pair)
            else {}
        )
        with-defaults);
  in
    lib.foldl utils.validate.success passed-tests [
      # -- unexpected attributes check
      {
        success = comparison.extra == {};
        error-msg = "got unexpected attributes:\n${fmt comparison.extra}";
      }
      # -- missing attributes check
      (let
        result = utils.attrs.compare defaults comparison.missing;
      in {
        success = result.missing == {};
        error-msg = "missing attributes:\n${fmt (fmt-leaves result.missing)}";
      })
      # -- passed tests check
      (let
        result = utils.attrs.compare passed-tests with-defaults;
        resolved = lib.mapAttrsRecursive (_: pair: (eval-pair pair).error-msg) result.missing;
      in {
        success = result.missing == {};
        error-msg = "incorrect attribute values:\n${fmt resolved}";
      })
    ];

  tests = [
    [
      (
        attrs
        {
          a = 2;
        }
        {
          a = value: {
            default = 2;
            check = lib.mod value 2 == 0;
            error-msg = "${toString value} is not divisible by 2";
          };
          b = value: {
            default = 3;
            check = lib.mod value 3 == 0;
            error-msg = "${toString value} is not divisible by 3";
          };
          c = {
            d = value: {
              default = 4;
            };
          };
        }
      )
      {
        a = 2;
        b = 3;
        c = {
          d = 4;
        };
      }
    ]
    [
      (builtins.tryEval (
        attrs
        {
          a = 1;
        }
        {
          a = value: {};
          b = value: {};
        }
      )).success
      false
    ]
    [
      (builtins.tryEval (
        attrs
        {
          a = 1;
        }
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
