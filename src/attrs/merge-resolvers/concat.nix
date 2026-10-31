{
  sundry,
  lib,
  ...
}: {
  base.concat = path: lhs: rhs:
    lib.toList lhs ++ lib.toList rhs;

  tests = {
    list-and-scalar = [
      (sundry.attrs.merge.concat [{A = [1 2];} {A = 3;}])
      {A = [1 2 3];}
    ];
    disjoint-keys = [
      (sundry.attrs.merge.concat [{A = 1;} {B = 2;}])
      {
        A = 1;
        B = 2;
      }
    ];
  };
}
