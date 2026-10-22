{lib, ...}: rec {
  not = predicate: value: !(predicate value);
  tests = {
    not-attrs = [((not lib.isAttrs) {A = 1;}) false];
    not-int = [((not lib.isInt) 0.5) true];
  };
}
