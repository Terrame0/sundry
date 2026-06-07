{
  lib,
  mlem,
  ...
}: rec {
  resolve-deps = transforms: let
    layers = lib.pipe transforms [
      (lib.mapAttrsToList (name: value-in: let
        value = mlem.attrs.validate value-in {
          deps = {
            default = [];
            check = value: lib.isList value && lib.all lib.isString value;
            desc = "must be a list of strings that represent the stage's dependencies";
          };
          transform = {
            check = value: lib.isFunction value;
            desc = "must be a transformation function";
          };
        };
      in {
        inherit name;
        inherit (value) deps;
        inherit (value) transform;
      }))
      mlem.list.topo-stratify
    ];
  in
    lib.foldl (
      acc: layer:
        lib.pipe layer [
          (map (entry: {
            ${entry.name} =
              entry.transform
              (lib.pipe entry.deps [
                (map (dep: {
                  name = dep;
                  value = acc.${dep};
                }))
                lib.listToAttrs
              ]);
          }))
          mlem.attrs.merge.no-collision
        ]
    ) {}
    layers;
  tests = [
    [
      (resolve-deps {
        first = {
          transform = _: 1;
        };
        second = {
          deps = ["first"];
          transform = prev: prev.first + 1;
        };
        third = {
          deps = ["first"];
          transform = prev: prev.first + 2;
        };
        fourth = {
          deps = ["second" "third"];
          transform = prev: prev.second + prev.third;
        };
      })
      {fourth = 5;}
    ]
  ];
}
