{lib, ...}: rec {
  remove-by-path = path: attrs:
    if path == []
    then attrs
    else let
      key = lib.head path;
      rest = lib.tail path;
    in
      if rest == []
      then removeAttrs attrs [key]
      else let
        recursion-result = remove-by-path rest attrs.${key};
      in
        if recursion-result != {}
        then attrs // {${key} = recursion-result;}
        else removeAttrs attrs [key];

  tests = [
    [
      (remove-by-path ["a" "b" "c"] {
        a = {
          b = {
            c = 1;
            d = 2;
          };
        };
      })
      {a = {b = {d = 2;};};}
    ]
    [
      (remove-by-path ["a" "b" "c"] {a = {b = {c = 1;};};})
      {}
    ]
  ];
}
