{...}: let
  does-throw-base = seq: value: !(builtins.tryEval (seq value true)).success;
in rec {
  does-throw = does-throw-base builtins.deepSeq;
  does-throw-whnf = does-throw-base builtins.seq;

  tests = {
    deep-throw = [(does-throw (throw "ABC")) true];
    deep-no-throw = [(does-throw "ABC") false];
    deep-attrset-throws = [(does-throw {a = throw "ABC";}) true];
    deep-list-throws = [(does-throw [(throw "ABC")]) true];
    whnf-throw = [(does-throw-whnf (throw "ABC")) true];
    whnf-no-throw = [(does-throw-whnf "ABC") false];
    whnf-attrset-lazy = [(does-throw-whnf {a = throw "ABC";}) false];
    whnf-list-lazy = [(does-throw-whnf [(throw "ABC")]) false];
  };
}
