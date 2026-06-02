{
  lib,
  utils,
  ...
}: rec {
  compare = lhs: rhs:
    utils.attrs.merge-with-resolvers (with utils.attrs.merge-resolvers; [
      (default: name: lhs: rhs:
        if name == "missing"
        then utils.attrs.remove-attr-by-path rhs lhs
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
        (path: _: lib.hasAttrByPath path rhs && lib.isAttrs (lib.getAttrFromPath path rhs))
        (path: value:
          if lib.hasAttrByPath path rhs
          then {
            matched = lib.setAttrByPath path [value (lib.getAttrFromPath path rhs)];
            missing = path;
          }
          else {extra = lib.setAttrByPath path value;})
        lhs)
    );

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
