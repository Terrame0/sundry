{
  lib,
  sundry,
  ...
}: rec {
  filter-matched-until = does-match: do-recurse: fn: (sundry.attrs.reform-matched-until
    does-match
    do-recurse
    (path: value: {
      inherit path;
      inherit value;
      omit = !(fn path value);
    }));
  filter-until = filter-matched-until (path: value: true);
  filter = filter-until (path: value: false);

  tests = let
    attrs = {
      A = 0;
      B = 1;
      C = {D = 2;};
      E = {F = {G = 0;};};
    };
  in [
    [
      (filter-matched-until
        (path: value: value != 0)
        (path: value: lib.length path > 1)
        (path: value: value != 1)
        attrs)
      {
        C = {D = 2;};
        E = {F = {G = 0;};};
      }
    ]
    [
      (filter-until
        (path: value: lib.length path > 1)
        (path: value: value != 1)
        attrs)
      {
        A = 0;
        C = {D = 2;};
        E = {F = {G = 0;};};
      }
    ]
    [
      (filter
        (path: value: value != 1)
        attrs)
      {
        A = 0;
        C = {D = 2;};
        E = {F = {G = 0;};};
      }
    ]
  ];
}
