{
  lib,
  utils,
  ...
}: rec {
  compare = lhs: rhs:
    utils.attrs.merge-with-resolvers (with utils.attrs.merge-resolvers; [
      # -- this is an intentional hack to insert an accumulator into the merge combinator
      # (forgive me, lord, for i have sinned)
      (default: name: lhs: rhs:
        if name == "missing"
        then utils.attrs.remove-attr-by-path rhs lhs
        else default name lhs rhs)
      recursive
      base.no-override
    ])
    (
      [
        {
          # -- this attribute initializes the accumulator
          missing = rhs;
          matched = {};
          extra = {};
        }
      ]
      ++ (lib.mapAttrsToListRecursive
        (path: value:
          if lib.hasAttrByPath path rhs
          then {
            matched = lib.setAttrByPath path [value (lib.getAttrFromPath path rhs)];
            # -- this actually removes a path from the accumulator
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
          b = {c = {d = "b.c.d";};};
          e = "e";
        };
        matched = {
          a = ["a" "a"];
        };
        missing = {
          b = {c = "b.c";};
          d = "d";
        };
      }
    ]
  ];
}
