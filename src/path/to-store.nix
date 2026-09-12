{
  lib,
  sundry,
  ...
}: rec {
  to-store = value:
    if lib.isPath value
    then
      builtins.path {
        path = value;
        name = lib.strings.sanitizeDerivationName (baseNameOf value);
      }
    else if lib.isString value && lib.hasPrefix builtins.storeDir value
    then value
    else throw "to-store: expected a path or a store-path string, got a '${builtins.typeOf value}'";
  tests = [
    # -- '[].txt' is reachable only through dynamic interpolation because
    # - '[' is not a legal bare path-literal character; its name is also
    # - illegal as a store component, which is what to-store sanitizes.
    [(lib.hasPrefix builtins.storeDir (to-store ./${"[].txt"})) true]
    [((builtins.getContext (to-store ./${"[].txt"})) != {}) true]
    # -- a store-resident string passes through unchanged
    [(to-store "${builtins.storeDir}/abc-x") "${builtins.storeDir}/abc-x"]
    [(sundry.does-throw (to-store "not-a-store-path")) true]
  ];
}
