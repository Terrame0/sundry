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
            desc = "each stage must have a transformation function defined";
          };
        };
      in {
        inherit name;
        inherit (value) deps;
        attrs = value.transform;
      }))
      mlem.list.topo-stratify
    ];
  in
    lib.foldl (
      acc: layer:
        mlem.attrs.merge.recursive.no-conflict
        (map (transform: transform.attrs acc) layer)
    ) {}
    layers;
  tests = [
    #[
    #  (resolve-deps {
    #    first = {
    #      transform = prev: {a = 1;};
    #    };
    #  })
    #  #[
    #  #  {
    #  #    name = "first";
    #  #    attrs = prev: {a = 1;};
    #  #  }
    #  #  {
    #  #    name = "B";
    #  #    deps = ["first"];
    #  #    attrs = prev: prev // {b = prev.a * 2;};
    #  #  }
    #  #  {
    #  #    name = "C";
    #  #    deps = ["first"];
    #  #    attrs = prev: prev // {c = prev.a * 3;};
    #  #  }
    #  #  {
    #  #    name = "D";
    #  #    deps = ["B" "C"];
    #  #    attrs = prev: prev // {d = prev.b + prev.c;};
    #  #  }
    #  #])
    #]
  ];
}
