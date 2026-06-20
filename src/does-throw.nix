{...}: rec {
  does-throw = value:
    !(builtins.tryEval value).success;
  tests = [
    [(does-throw (throw "ABC")) true]
    [(does-throw "ABC") false]
  ];
}
