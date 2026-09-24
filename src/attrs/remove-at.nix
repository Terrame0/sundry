{lib, ...}: rec {
  remove-at = path: attrs:
    if path == []
    then attrs
    else let
      key = lib.head path;
      rest = lib.tail path;
    in
      if rest == []
      then removeAttrs attrs [key]
      else let
        recursion-result = remove-at rest attrs.${key};
      in
        if recursion-result != {}
        then attrs // {${key} = recursion-result;}
        else removeAttrs attrs [key];

  tests = [
    [
      (remove-at ["A" "B" "C"] {
        A = {
          B = {
            C = 1;
            D = 2;
          };
        };
      })
      {A = {B = {D = 2;};};}
    ]
    [
      (remove-at ["A" "B" "C"] {A = {B = {C = 1;};};})
      {}
    ]
    [
      (remove-at ["A"] {
        A = 1;
        B = 2;
      })
      {B = 2;}
    ]
    [(remove-at [] {A = 1;}) {A = 1;}]
  ];
}
