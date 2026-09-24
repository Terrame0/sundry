{lib, ...}: rec {
  get = lib.getAttrFromPath;
  tests = [
    [(get ["A" "B" "C"] {A.B.C = 1;}) 1]
    [(get ["A" "B"] {A.B = {C = 1;};}) {C = 1;}]
    [(get [] {A = 1;}) {A = 1;}]
  ];
}
