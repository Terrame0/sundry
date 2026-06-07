{
  lib,
  mlem,
  ...
}: let
  compare-base = cond: lhs: rhs:
    mlem.attrs.merge-with-resolvers (with mlem.attrs.merge-resolvers; [
      (default: name: lhs: rhs:
        if name == "missing"
        then mlem.attrs.remove-by-path rhs lhs
        else default name lhs rhs)
      recursive
      base.no-collision
    ])
    (
      [
        {
          missing = rhs;
          matched = {};
          extra = {};
        }
      ]
      ++ (lib.mapAttrsToListRecursiveCond
        # -- only recurse when rhs also has an attrset here
        # otherwise treat lhs subtree as a leaf
        (path: _: let
          rhs-value = lib.getAttrFromPath path rhs;
        in
          lib.hasAttrByPath path rhs
          && lib.isAttrs rhs-value
          && cond rhs-value)
        (path: value:
          if lib.hasAttrByPath path rhs
          then {
            matched = lib.setAttrByPath path [value (lib.getAttrFromPath path rhs)];
            missing = path;
          }
          else {extra = lib.setAttrByPath path value;})
        lhs)
    );
in rec {
  compare = compare-base lib.isAttrs;
  compare-until = compare-base;

  tests = [
    [
      (compare {
          a = "a";
          b = {c = {d = "b.c.d";};};
          e = "e";
        } {
          a = "a";
          b = {c = "b.c";};
          d = "d";
        })
      {
        extra = {
          e = "e";
        };
        matched = {
          b = {c = [{d = "b.c.d";} "b.c"];};
          a = ["a" "a"];
        };
        missing = {
          d = "d";
        };
      }
    ]
  ];
}
