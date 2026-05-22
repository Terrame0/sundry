{lib, ...}: rec {
  incl-tail = list:
    if lib.length list != 1
    then lib.tail list
    else list;
  tests = [
    [(incl-tail [1 2]) [2]]
    [(incl-tail [1]) [1]]
  ];
}
