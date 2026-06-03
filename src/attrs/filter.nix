{
  lib,
  mlem,
  ...
}: let
  filter-base = base: fn:
    base (path: value: {
      inherit path;
      inherit value;
      omit = !(fn path value);
    });
in rec {
  filter = filter-base mlem.attrs.reform;
  filter-until = cond: filter-base (mlem.attrs.reform-until cond);
  tests = [
    [
      (filter-until
        (path: value: lib.last path == "f")
        (path: value: lib.isInt value && lib.mod value 2 == 1)
        {
          a = {
            b = 3;
            c = 4;
            d = {e = 7;};
            f = {g = 11;};
          };
        })
      {
        a = {
          b = 3;
          d = {e = 7;};
        };
      }
    ]
  ];
}
