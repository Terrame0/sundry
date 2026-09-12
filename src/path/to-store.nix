{
  lib,
  sundry,
  ...
}: let
  # -- the top-level store object that contains a store-resident path
  store-root = path-str:
    lib.pipe path-str [
      (lib.splitString "/")
      (lib.take (lib.length (lib.splitString "/" builtins.storeDir) + 1))
      (lib.concatStringsSep "/")
    ];
in rec {
  to-store = value:
    if lib.isPath value
    then
      if lib.hasPrefix builtins.storeDir (toString value)
      then
        builtins.appendContext
        (toString value) {"${store-root (toString value)}" = {path = true;};}
      else
        builtins.path {
          path = value;
          name = lib.strings.sanitizeDerivationName (baseNameOf value);
        }
    else if lib.isString value && lib.hasPrefix builtins.storeDir value
    then value
    else throw "to-store: expected a path or a store-path string, got a '${builtins.typeOf value}'";
  tests = [
    # -- a store-resident path is not copied: it becomes a context-carrying
    # - string that points into the store object already holding it
    [(lib.hasPrefix builtins.storeDir (to-store ./${"[].txt"})) true]
    [((builtins.getContext (to-store ./${"[].txt"})) != {}) true]
    # -- a store-resident string passes through unchanged
    [(to-store "${builtins.storeDir}/abc-x") "${builtins.storeDir}/abc-x"]
    [(sundry.does-throw (to-store "not-a-store-path")) true]
  ];
}
