{lib, ...}: rec {
  not = predicate: value: !(predicate value);
  tests = {
    attrs = [((not lib.isAttrs) {A = 1;}) false];
    int = [((not lib.isInt) 0.5) true];
  };
}
