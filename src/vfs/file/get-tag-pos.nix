{
  sundry,
  lib,
  ...
}: rec {
  get-tag-pos = expr-fn: file:
    lib.findFirst
    (i:
      sundry.boolean.expr expr-fn
      [(sundry.list.at i file.tag-list)])
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
  in {
    tag-x-one = [(get-tag-pos (_: with _; tag {x = "1";}) file) 0];
    tag-x-missing = [(get-tag-pos (_: with _; tag {x = "2";}) file) (-1)];
    tag-x-empty = [(get-tag-pos (_: with _; tag {x = [];}) file) 0];
    tag-x-multi = [(get-tag-pos (_: with _; tag {x = ["1" "2"];}) file) 0];
    tag-yz-one = [(get-tag-pos (_: with _; tag ({y = "1";} // {z = "1";})) file) 1];
    tag-yz-missing = [(get-tag-pos (_: with _; tag ({y = "2";} // {z = "1";})) file) (-1)];
    tag-yz-empty = [(get-tag-pos (_: with _; tag ({y = [];} // {z = "1";})) file) 1];
    tag-yz-multi = [(get-tag-pos (_: with _; tag ({y = ["1" "2"];} // {z = "1";})) file) 1];
    tag-xy-cross = [(get-tag-pos (_: with _; tag ({x = "1";} // {y = "1";})) file) (-1)];
    no-tags = [(get-tag-pos (_: with _; tag {x = "1";}) blank) (-1)];
  };
}
