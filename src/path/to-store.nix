{
  lib,
  fixtures-dir,
  sundry,
  ...
}: rec {
  to-store = value:
    if lib.isPath value
    then
      if lib.hasPrefix builtins.storeDir (toString value)
      then
        builtins.appendContext
        (toString value) {"${sundry.path.store-root (toString value)}" = {path = true;};}
      else
        builtins.path {
          path = value;
          name = lib.strings.sanitizeDerivationName (baseNameOf value);
        }
    else if lib.isString value && lib.hasPrefix builtins.storeDir value
    then value
    else throw "to-store: expected a path or a store-path string, got a '${builtins.typeOf value}'";
  tests = {
    # -- a store-resident path is not copied: it becomes a context-carrying
    # - string that points into the store object already holding it
    path-is-stored = [(lib.hasPrefix builtins.storeDir (to-store (fixtures-dir + "/[].txt"))) true];
    path-has-context = [((builtins.getContext (to-store (fixtures-dir + "/[].txt"))) != {}) true];
    # -- a store-resident string passes through unchanged
    store-string-passthrough = [(to-store "${builtins.storeDir}/abc-x") "${builtins.storeDir}/abc-x"];
    non-store-string = [(sundry.does-throw (to-store "not-a-store-path")) true];
  };
}
