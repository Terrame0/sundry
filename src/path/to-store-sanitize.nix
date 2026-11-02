{
  lib,
  pkgs,
  sundry,
  fixtures-dir,
  ...
}: rec {
  # -- the name is sanitized because a store path
  # - cannot hold arbitrary characters (e.g. '{')
  to-store-sanitize = value:
    if lib.isPath value
    then
      builtins.path {
        path = value;
        name = lib.strings.sanitizeDerivationName (baseNameOf value);
      }
    else if lib.isDerivation value
    then toString value
    else throw "path.to-store-sanitize: expected a path or a derivation, got a '${builtins.typeOf value}'";

  tests = let
    drv = pkgs.runCommandLocal "to-store-sanitize-derivation" {} "mkdir $out";
  in {
    # -- paths are copied under a sanitized name, so a tag in the basename
    # - cannot produce an illegal store path
    path-is-stored = [(lib.hasPrefix builtins.storeDir (to-store-sanitize (fixtures-dir + "/[].txt"))) true];
    path-has-context = [((builtins.getContext (to-store-sanitize (fixtures-dir + "/[].txt"))) != {}) true];
    path-copy-is-stable = [(to-store-sanitize (fixtures-dir + "/[].txt")) (to-store-sanitize (fixtures-dir + "/[].txt"))];
    path-name-is-sanitized = [
      (lib.hasSuffix "-.txt" (to-store-sanitize (fixtures-dir + "/[].txt")))
      true
    ];
    derivation-unchanged = [(to-store-sanitize drv) (toString drv)];
    derivation-keeps-context = [(builtins.getContext (to-store-sanitize drv)) (builtins.getContext (toString drv))];
    # -- store-path strings are rejected: fabricating context on them can lead to errors 
    # - in nix implementations with lazy trees where appendContext fails on ensurePath 
    # - because in such implementation isValidPath is false for lazily mounted paths (e.g. a flake input)
    rejects-store-string = [(sundry.does-throw (to-store-sanitize "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-x")) true];
    rejects-plain-string = [(sundry.does-throw (to-store-sanitize "not-a-store-path")) true];
  };
}
