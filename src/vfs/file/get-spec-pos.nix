{
  lib,
  mlem,
  ...
}: {
  get-spec-pos = spec: file:
    (mlem.for
      [
        (lib.length file.specs - 1)
        (i: i - 1)
        (i: i >= -1)
      ]
      {pos = -1;}
      (_: i: {
        break = let
          comparison =
            mlem.attrs.compare spec
            (mlem.list.at i file.specs);
        in
          (lib.all lib.id
            (lib.mapAttrsToList
              (name: value:
                mlem.list.at 0 value
                == mlem.list.at 1 value
                || mlem.list.at 0 value == {})
              comparison.matched))
          && (comparison.extra == {});
        pos = i;
      })).pos;

  tests = let
    file = {
      text = "x";
      specs = [{x = "1";} {y = "1";} {z = "2";}];
    };
  in [
    [(mlem.vfs.file.get-spec-pos {y = "1";} file) 1]
    [(mlem.vfs.file.get-spec-pos {z = "2";} file) 2]
    [(mlem.vfs.file.get-spec-pos {w = "1";} file) (-1)]
  ];
}
