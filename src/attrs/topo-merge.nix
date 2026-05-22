{
  lib,
  utils,
  ...
}: rec {
  topo-merge = transforms: let
    sorted =
      utils.list.topo-stratify
      transforms;
  in
    lib.foldl (
      acc: layer:
        utils.attrs.merge-recursive [
          acc
          (utils.attrs.merge-recursive-no-override
            (map (transform: transform.attrs acc) layer))
        ]
    ) {}
    sorted;
  tests = [
    [
      (topo-merge [
        {
          name = "A";
          attrs = prev: {a = 1;};
        }
        {
          name = "B";
          depends-on = ["A"];
          attrs = prev: {b = prev.a * 2;};
        }
        {
          name = "C";
          depends-on = ["A"];
          attrs = prev: {c = prev.a * 3;};
        }
        {
          name = "D";
          depends-on = ["B" "C"];
          attrs = prev: {d = prev.b + prev.c;};
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
