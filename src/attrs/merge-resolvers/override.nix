{sundry, ...}: rec {
  base.override = path: lhs: rhs: rhs;
  tests = {
    returns-rhs = [(base.override ["_"] {A = 1;} {A = 2;}) {A = 2;}];
    merge-two-attrsets = [
      (sundry.attrs.merge.override [{A = 1;} {B = 2;}])
      {
        A = 1;
        B = 2;
      }
    ];
  };
}
