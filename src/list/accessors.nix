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
  tests = {
    at-first = [(at 0 [1 2]) 1];
    at-second = [(at 1 [1 2]) 2];
    incl-init-pair = [(incl-init [1 2]) [1]];
    incl-init-singleton = [(incl-init [1]) [1]];
    incl-tail-pair = [(incl-tail [1 2]) [2]];
    incl-tail-singleton = [(incl-tail [1]) [1]];
    excl-last-pair = [(excl-last [1 2]) 2];
    excl-last-singleton = [(excl-last [1]) null];
    excl-head-pair = [(excl-head [1 2]) 1];
    excl-head-singleton = [(excl-head [1]) null];
  };
}
