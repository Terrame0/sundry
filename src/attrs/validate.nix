{
  lib,
  mlem,
  ...
}: let
  not-leaf = attrs:
    lib.isAttrs attrs
    && !(attrs ? check
      || attrs ? default
      || attrs == {});
  compare-until-leaf = mlem.attrs.compare-until not-leaf;
  collapse-until =
    lib.mapAttrsToListRecursiveCond (path: not-leaf);
  filter-map = fn: attrs:
    lib.pipe attrs [
      (collapse-until
        (path: attrs: let
          result = fn path attrs;
        in
          if !result.omit
          then
            lib.setAttrByPath
            path
            result.value
          else {}))
      lib.mergeAttrsList
    ];
  concat-path = strs: lib.concatStringsSep " -> " (map (str: "'${str}'") strs);
  format = lib.generators.toPretty {multiline = false;};
in rec {
  validate = attrs: template-in: let
    template = lib.mapAttrsRecursiveCond not-leaf (path: value: let
      structure-msg = ''
        'check' - an attribute value validation function
        'desc' - a description of a valid value
        'default' - a default attribute value
        'nullable' - a flag that indicates whether the value can be null
      '';
    in
      if !(lib.isAttrs value)
      then
        throw ''
          an attribute template must be an attribute set with the following structure:
          ${structure-msg}
        ''
      else if
        (compare-until-leaf value {
          check = null;
          desc = null;
          default = null;
          nullable = null;
        }).extra
        == {}
      then value
      else
        throw ''
          an attribute template can only have the following attributes:
          ${structure-msg}
        '')
    template-in;

    compared-with-template = compare-until-leaf attrs template;

    defaults =
      filter-map (
        path: value: {
          value = [value.default value];
          omit = !(value ? default);
        }
      )
      compared-with-template.missing;

    matched-with-defaults =
      mlem.attrs.merge.recursive.no-collision
      [compared-with-template.matched defaults];

    missing =
      lib.pipe
      (compare-until-leaf defaults compared-with-template.missing).missing
      [
        (collapse-until
          (path: value: "  ${concat-path path} | ${value.desc or "..."}"))
        (lib.concatStringsSep "\n")
      ];

    extra =
      lib.pipe
      compared-with-template.extra
      [
        (collapse-until
          (path: value: "  ${concat-path path} = ${format value}"))
        (lib.concatStringsSep "\n")
      ];

    did-not-pass = lib.pipe matched-with-defaults [
      (collapse-until (
        path: pair: let
          value = mlem.list.at 0 pair;
          spec = mlem.list.at 1 pair;
          passed =
            if spec.nullable or false && value == null
            then true
            else if !(spec ? check)
            then true
            else if !(spec ? desc)
            then throw "attribute spec that has a 'check' attribute must also have a 'desc' attribute"
            else let test-result = spec.check value; in assert builtins.isBool test-result; test-result;
        in
          if passed
          then []
          else ["  ${concat-path path} = ${format value} | ${spec.desc}"]
      ))
      lib.concatLists
      (lib.concatStringsSep "\n")
    ];
    values =
      lib.mapAttrsRecursive
      (path: pair: mlem.list.at 0 pair)
      matched-with-defaults;
  in
    lib.foldl
    mlem.check-success
    values [
      {
        success = did-not-pass == "";
        error-msg = "incorrect attribute values:\n${did-not-pass}";
      }
      {
        success = extra == "";
        error-msg = "got extra attributes:\n${extra}";
      }
      {
        success = missing == "";
        error-msg = "missing attributes:\n${missing}";
      }
    ];

  tests = [
    [
      (
        validate
        {
          a = 1;
          b = 2;
        }
        {
          a = {
            check = value: lib.mod value 1 == 0;
            desc = "must be odd";
          };
          b = {
            default = null;
            nullable = true;
          };
          c = {
            d = {
              default = 3;
              check = value: lib.mod value 3 == 0;
              desc = "must be divisible by 3";
            };
          };
        }
      )
      {
        a = 1;
        b = 2;
        c = {
          d = 3;
        };
      }
    ]
    [
      (builtins.tryEval (
        validate
        {a = 1;}
        {
          a = {};
          b = {};
        }
      )).success
      false
    ]
    [
      (builtins.tryEval (
        validate
        {a = 1;}
        {
          a = {
            default = 2;
            check = value: lib.mod value 2 == 0;
            desc = "must be even";
          };
        }
      )).success
      false
    ]
    [
      (builtins.tryEval (
        validate
        {
          a = 1;
          b = 2;
        }
        {
          a = {};
        }
      )).success
      false
    ]
  ];
}
