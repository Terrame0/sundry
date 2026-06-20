{
  sundry,
  lib,
  ...
}: rec {
  get.tag-pos = tag-spec: file:
    lib.findFirst
    (i:
      sundry.vfs.tags-match
      tag-spec (sundry.list.at i file.tag-list))
    (-1)
    (sundry.range [(lib.length file.tag-list)]);
  tests = let
    file = {
      text = "x";
      tag-list = [{x = "1";} ({y = "1";} // {z = "1";})];
    };
    blank = {
      text = "y";
      tag-list = [];
    };
  in [
    [(get.tag-pos {x = "1";} file) 0]
    [(get.tag-pos {x = "2";} file) (-1)]
    [(get.tag-pos {x = [];} file) 0]
    [(get.tag-pos {x = ["1" "2"];} file) 0]
    [(get.tag-pos ({y = "1";} // {z = "1";}) file) 1]
    [(get.tag-pos ({y = "2";} // {z = "1";}) file) (-1)]
    [(get.tag-pos ({y = [];} // {z = "1";}) file) 1]
    [(get.tag-pos ({y = ["1" "2"];} // {z = "1";}) file) 1]
    [(get.tag-pos ({x = "1";} // {y = "1";}) file) (-1)]
    [(get.tag-pos {x = "1";} blank) (-1)]
    [(get.tag-pos {x = null;} file) 1]
    [(get.tag-pos {w = null;} file) 0]
    [(get.tag-pos ({y = null;} // {z = "1";}) file) (-1)]
  ];
}
