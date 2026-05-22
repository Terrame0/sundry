{lib, ...}: rec {
  incl-init = list:
    if lib.length list != 1
    then lib.init list
    else list;
  tests = [
    [(incl-init [1 2]) [1]]
    [(incl-init [1]) [1]]
  ];
}
