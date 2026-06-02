{
  lib,
  utils,
  flake-root,
  ...
}: [
  [
    (utils.attrs.topo-transform [
      {
        name = "import-stage";
        attrs = prev:
          utils.dir.from-real
          "${flake-root}/tests/vfs-test-dir/preprocessing";
      }
      {
        name = "spec-resolution-stage";
        depends-on = ["import-stage"];
        attrs = prev:
          utils.attrs.reform-cond
          (path: value: !(value ? contents))
          (path: value: {
            path = map (path: "${lib.concatStrings (utils.string.outside "[" "]" path)}") path;
            value =
              value
              // {
                specs = map (dir:
                  utils.attrs.merge.recursive.no-conflict
                  (map (spec-str: let
                    spec-parts = lib.splitString ":" spec-str;
                  in {${lib.head spec-parts} = lib.last spec-parts;})
                  (utils.string.between "[" "]" dir)))
                path;
              };
          })
          prev;
      }
    ])
  ]
]
