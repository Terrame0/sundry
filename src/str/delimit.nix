{
  lib,
  mlem,
  ...
}: rec {
  delimit = lsep: rsep: str: let
    recurse = {
      current-pos ? 0,
      lsep-stack ? [],
      inside-substrs ? [],
      outside-start ? 0,
      outside-substrs ? [],
    }: let
      search = mlem.str.find-after current-pos;
      str-end = mlem.str.len str;
      lsep-current-pos = mlem.is-null (search lsep str) str-end;
      rsep-current-pos = mlem.is-null (search rsep str) str-end;
      lsep-offset = mlem.str.len lsep;
      rsep-offset = mlem.str.len rsep;
      depth = lib.length lsep-stack;
      get-substr = from: to: lib.substring from (to - from) str;
      on-lsep = recurse {
        current-pos = lsep-current-pos + lsep-offset;
        lsep-stack = lsep-stack ++ [(lsep-current-pos + lsep-offset)];
        inherit outside-start;
        inherit inside-substrs;
        outside-substrs =
          if depth == 0
          then
            outside-substrs
            ++ [
              {
                substr = get-substr outside-start lsep-current-pos;
                pos = outside-start;
                inherit depth;
              }
            ]
          else outside-substrs;
      };
      on-rsep = recurse {
        current-pos = rsep-current-pos + rsep-offset;
        inside-substrs =
          inside-substrs
          ++ [
            {
              substr = get-substr (lib.last lsep-stack) rsep-current-pos;
              pos = lib.last lsep-stack;
              inherit depth;
            }
          ];
        lsep-stack = lib.init (
          if lsep-stack != []
          then lsep-stack
          else throw "unmatched rsep"
        );
        outside-start =
          if depth == 1
          then rsep-current-pos + rsep-offset
          else outside-start;
        inherit outside-substrs;
      };
    in
      if lsep-current-pos == str-end && rsep-current-pos == str-end
      then
        if lsep-stack == []
        then {
          inside = inside-substrs;
          outside =
            outside-substrs
            ++ [
              {
                substr = get-substr outside-start str-end;
                pos = outside-start;
                inherit depth;
              }
            ];
        }
        else throw "unmatched lsep"
      else
        mlem.best-by (l: r: l < r) [
          [lsep-current-pos on-lsep]
          [rsep-current-pos on-rsep]
        ];
  in
    recurse {};
  tests = let
    s = pos: substr: depth: {inherit pos substr depth;};
    ans = inside: outside: {inherit inside outside;};
  in [
    [
      (delimit "[" "]" "[A][B][C]")
      (ans [(s 1 "A" 1) (s 4 "B" 1) (s 7 "C" 1)] [(s 0 "" 0) (s 3 "" 0) (s 6 "" 0) (s 9 "" 0)])
    ]
    [
      (delimit "[" "]" "X[A]Y[B]Z")
      (ans [(s 2 "A" 1) (s 6 "B" 1)] [(s 0 "X" 0) (s 4 "Y" 0) (s 8 "Z" 0)])
    ]
    [
      (delimit "[" "]" "ABC")
      (ans [] [(s 0 "ABC" 0)])
    ]
    [
      (delimit "[" "]" "")
      (ans [] [(s 0 "" 0)])
    ]
    [
      (delimit "[" "]" "[A[B]A]")
      (ans [(s 3 "B" 2) (s 1 "A[B]A" 1)] [(s 0 "" 0) (s 7 "" 0)])
    ]
  ];
}
