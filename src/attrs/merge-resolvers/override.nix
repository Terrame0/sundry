{...}: rec {
  base.override = name: lhs: rhs: rhs;
  tests = [[(base.override "_" {a = 1;} {a = 2;}) {a = 2;}]];
}
