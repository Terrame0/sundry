{
  lib,
  mlem,
  flake-root,
  ...
}: [
  [
    (mlem.attrs.topo-transform [
      {
        name = "import-stage";
        attrs = prev:
          mlem.dir.from-real
          "${flake-root}/tests/vfs-test-dir/preprocessing";
      }
      {
        name = "spec-resolution-stage";
        depends-on = ["import-stage"];
        attrs = prev:
          mlem.attrs.reform-cond
          (path: value: !(value ? contents))
          (path: value: {
            path = map (path: "${lib.concatStrings (mlem.string.outside "[" "]" path)}") path;
            value =
              value
              // {
                specs = map (dir:
                  mlem.attrs.merge.recursive.no-conflict
                  (map (spec-str: let
                    spec-parts = lib.splitString ":" spec-str;
                  in {${lib.head spec-parts} = lib.last spec-parts;})
                  (mlem.string.between "[" "]" dir)))
                path;
              };
          })
          prev;
      }
    ])
  ]
]
