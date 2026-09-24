{...}: let
  does-throw-base = seq: value: !(builtins.tryEval (seq value true)).success;
in rec {
  does-throw = does-throw-base builtins.deepSeq;
  does-throw-whnf = does-throw-base builtins.seq;
  tests = [
    [(does-throw (throw "ABC")) true]
    [(does-throw "ABC") false]
    [(does-throw {a = throw "ABC";}) true]
    [(does-throw [(throw "ABC")]) true]
    [(does-throw-whnf (throw "ABC")) true]
    [(does-throw-whnf "ABC") false]
    [(does-throw-whnf {a = throw "ABC";}) false]
    [(does-throw-whnf [(throw "ABC")]) false]
  ];
}
