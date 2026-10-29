{
  lib,
  pkgs,
  fixtures-dir,
  sundry,
  ...
}: rec {
  to-store-str = value:
    if lib.isPath value
    then
      if lib.hasPrefix builtins.storeDir (toString value)
      then builtins.appendContext (toString value) {"${sundry.path.store-root (toString value)}" = {path = true;};}
      else
        builtins.path {
          path = value;
          name = lib.strings.sanitizeDerivationName (baseNameOf value);
        }
    else if lib.isDerivation value
    then toString value
    else if lib.isString value && lib.hasPrefix builtins.storeDir value
    then
      if builtins.getContext value == {}
      then builtins.appendContext value {"${sundry.path.store-root value}" = {path = true;};}
      else value
    else throw "path.to-store-str: expected a path, a derivation, or a store-path string, got a '${builtins.typeOf value}'";
  tests = let
    raw-store-string = builtins.unsafeDiscardStringContext (toString (builtins.toFile "to-store-str-fixture" "x"));
    context-store-string = "${pkgs.runCommandLocal "to-store-str-unbuilt" {} "mkdir $out"}";
    deriv = pkgs.runCommandLocal "to-store-str-derivation" {} "mkdir $out";
  in {
    # -- a store-resident path is not copied: it becomes a context-carrying
    # - string that points into the store object already holding it
    path-is-stored = [(lib.hasPrefix builtins.storeDir (to-store-str (fixtures-dir + "/[].txt"))) true];
    path-has-context = [((builtins.getContext (to-store-str (fixtures-dir + "/[].txt"))) != {}) true];
    # -- a context-free store string gains a context on its store root
    store-string-unchanged = [(to-store-str raw-store-string) raw-store-string];
    store-string-gains-context = [((builtins.getContext (to-store-str raw-store-string)) != {}) true];
    # -- a context-carrying store string passes through, so an unbuilt output
    # - is not forced by appendContext's existence check
    context-string-keeps-context = [(builtins.getContext (to-store-str context-store-string)) (builtins.getContext context-store-string)];
    context-string-unchanged = [(to-store-str context-store-string) context-store-string];
    # -- a derivation becomes its output path; 'toString' keeps the result
    # - context-carrying without forcing the output to exist
    derivation-unchanged = [(to-store-str deriv) (toString deriv)];
    derivation-keeps-context = [(builtins.getContext (to-store-str deriv)) (builtins.getContext (toString deriv))];
    non-store-string = [(sundry.does-throw (to-store-str "not-a-store-path")) true];
  };
}
