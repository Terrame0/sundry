{lib, ...}: rec {
  excl-head = list:
    if lib.length list != 1
    then lib.head list
    else null;
  tests = [
    [(excl-head [1 2]) 1]
    [(excl-head [1]) null]
  ];
}
