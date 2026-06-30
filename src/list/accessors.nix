{lib, ...}: rec {
  at = lib.flip lib.elemAt;
  incl-init = list:
    if lib.length list != 1
    then lib.init list
    else list;
  incl-tail = list:
    if lib.length list != 1
    then lib.tail list
    else list;
  excl-last = list:
    if lib.length list != 1
    then lib.last list
    else null;
  excl-head = list:
    if lib.length list != 1
    then lib.head list
    else null;
  tests = [
    [(at 0 [1 2]) 1]
    [(at 1 [1 2]) 2]
    [(incl-init [1 2]) [1]]
    [(incl-init [1]) [1]]
    [(incl-tail [1 2]) [2]]
    [(incl-tail [1]) [1]]
    [(excl-last [1 2]) 2]
    [(excl-last [1]) null]
    [(excl-head [1 2]) 1]
    [(excl-head [1]) null]
  ];
}
