{
  lib,
  mlem,
  ...
}: {
  get-tag-pos = tag: file:
    (mlem.for
      [
        (lib.length file.tags - 1)
        (i: i - 1)
        (i: i >= -1)
      ]
      {pos = -1;}
      (_: i: {
        break = let
          comparison =
            mlem.attrs.compare tag
            (mlem.list.at i file.tags);
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
      tags = [{x = "1";} {y = "1";} {z = "2";}];
    };
  in [
    [(mlem.vfs.file.get-tag-pos {y = "1";} file) 1]
    [(mlem.vfs.file.get-tag-pos {z = "2";} file) 2]
    [(mlem.vfs.file.get-tag-pos {w = "1";} file) (-1)]
  ];
}
