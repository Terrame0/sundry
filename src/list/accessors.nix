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
    incl-init-two-elements = [(incl-init [1 2]) [1]];
    incl-init-single-element = [(incl-init [1]) [1]];
    incl-tail-two-elements = [(incl-tail [1 2]) [2]];
    incl-tail-single-element = [(incl-tail [1]) [1]];
    excl-last-two-elements = [(excl-last [1 2]) 2];
    excl-last-single-element = [(excl-last [1]) null];
    excl-head-two-elements = [(excl-head [1 2]) 1];
    excl-head-single-element = [(excl-head [1]) null];
  };
}
