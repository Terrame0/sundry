{lib, ...}: rec {
  excl-last = list:
    if lib.length list != 1
    then lib.last list
    else null;
  tests = [
    [(excl-last [1 2]) 2]
    [(excl-last [1]) null]
  ];
}
