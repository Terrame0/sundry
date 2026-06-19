{
  lib,
  sundry,
  ...
}: let
  filter-base = base: fn:
    base (path: value: {
      inherit path;
      inherit value;
      omit = !(fn path value);
    });
in rec {
  filter = filter-base sundry.attrs.reform;
  filter-until = cond: filter-base (sundry.attrs.reform-until cond);
  tests = [
    [
      (filter-until
        (path: value: lib.last path == "F")
        (path: value: lib.isInt value && lib.mod value 2 == 1)
        {
          A = {
            B = 3;
            C = 4;
            D = {E = 7;};
            F = {G = 11;};
          };
        })
      {
        A = {
          B = 3;
          D = {E = 7;};
        };
      }
    ]
    [
      (filter-until
        (path: value: !lib.isAttrs value)
        (path: value: false)
        {
          A = 1;
          B = 2;
        })
      {}
    ]
    [
      (filter-until
        (path: value: !lib.isAttrs value)
        (path: value: true)
        {
          A = 1;
          B = 2;
        })
      {
        A = 1;
        B = 2;
      }
    ]
  ];
}
