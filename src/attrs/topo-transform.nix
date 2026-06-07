{
  lib,
  mlem,
  ...
}: rec {
  topo-transform = transforms: let
    layers =
      mlem.list.topo-stratify
      transforms;
  in
    lib.foldl (
      acc: layer:
        mlem.attrs.merge.recursive.no-conflict
        (map (transform: transform.attrs acc) layer)
    ) {}
    layers;
  tests = [
    [
      (topo-transform [
        {
          name = "A";
          attrs = prev: {a = 1;};
        }
        {
          name = "B";
          deps = ["A"];
          attrs = prev: prev // {b = prev.a * 2;};
        }
        {
          name = "C";
          deps = ["A"];
          attrs = prev: prev // {c = prev.a * 3;};
        }
        {
          name = "D";
          deps = ["B" "C"];
          attrs = prev: prev // {d = prev.b + prev.c;};
        }
      ])
      {
        a = 1;
        b = 2;
        c = 3;
        d = 5;
      }
    ]
  ];
}
