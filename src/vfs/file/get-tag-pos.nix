{
  lib,
  sundry,
  ...
}: {
  get-tag-pos = tag: file:
    (sundry.for
      [
        (lib.length file.tags - 1)
        (i: i - 1)
        (i: i >= -1)
      ]
      {pos = -1;}
      (_: i: {
        break = let
          comparison =
            sundry.attrs.compare tag
            (sundry.list.at i file.tags);
        in
          (lib.all lib.id
            (lib.mapAttrsToList
              (name: value:
                sundry.list.at 0 value
                == sundry.list.at 1 value
                || sundry.list.at 0 value == {})
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
    [(sundry.vfs.file.get-tag-pos {y = "1";} file) 1]
    [(sundry.vfs.file.get-tag-pos {z = "2";} file) 2]
    [(sundry.vfs.file.get-tag-pos {w = "1";} file) (-1)]
  ];
}
