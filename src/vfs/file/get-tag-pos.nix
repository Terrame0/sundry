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
              (name: value: let
                expected-list = sundry.list.at 0 value;
                current-value = sundry.list.at 1 value;
              in
                expected-list
                == []
                || sundry.list.contains current-value expected-list)
              comparison.matched))
          && (comparison.extra == {});
        pos = i;
      })).pos;

  tests = let
    file = {
      text = "x";
      tags = [{x = "1";}];
    };
  in [
    [(sundry.vfs.file.get-tag-pos {x = "1";} file) 0]
    [(sundry.vfs.file.get-tag-pos {x = "2";} file) (-1)]
    [(sundry.vfs.file.get-tag-pos {x = ["1" "2"];} file) 0]
    [(sundry.vfs.file.get-tag-pos {x = [];} file) 0]
    [(sundry.vfs.file.get-tag-pos {y = "1";} file) (-1)]
  ];
}
