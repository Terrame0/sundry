{
  lib,
  sundry,
  ...
}: let
  compare-base = cond: lhs: rhs:
    sundry.attrs.merge-with-resolvers (with sundry.attrs.merge-resolvers; [
      (default: name: lhs: rhs:
        if name == "missing"
        then sundry.attrs.remove-by-path rhs lhs
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
          A = "A";
          B = {C = {D = "B.C.D";};};
          E = "E";
        } {
          A = "A";
          B = {C = "B.C";};
          D = "D";
        })
      {
        extra = {
          E = "E";
        };
        matched = {
          B = {C = [{D = "B.C.D";} "B.C"];};
          A = ["A" "A"];
        };
        missing = {
          D = "D";
        };
      }
    ]
    [
      (compare {
          A = 1;
          B = 2;
        } {
          A = 1;
          B = 2;
        })
      {
        extra = {};
        matched = {
          A = [1 1];
          B = [2 2];
        };
        missing = {};
      }
    ]
    [
      (compare {A = 1;} {B = 2;})
      {
        extra = {A = 1;};
        matched = {};
        missing = {B = 2;};
      }
    ]
    [
      (compare {} {})
      {
        extra = {};
        matched = {};
        missing = {};
      }
    ]
  ];
}
