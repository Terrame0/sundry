{lib, ...}: rec {
  get = lib.getAttrFromPath;

  tests = {
    nested-path = [(get ["A" "B" "C"] {A.B.C = 1;}) 1];
    parent-path = [(get ["A" "B"] {A.B = {C = 1;};}) {C = 1;}];
    empty-path = [(get [] {A = 1;}) {A = 1;}];
  };
}
