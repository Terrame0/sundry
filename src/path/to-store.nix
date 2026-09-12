{lib, ...}: rec {
  to-store = path:
    if lib.isPath path
    then
      builtins.path {
        inherit path;
        name = lib.strings.sanitizeDerivationName (baseNameOf path);
      }
    else path;
  tests = [
    [(to-store "/abs/path") "/abs/path"]
    # -- '[].txt' is reachable only through dynamic interpolation because
    # - '[' is not a legal bare path-literal character; its name is also
    # - illegal as a store component, which is what to-store sanitizes.
    [(lib.hasSuffix "-.txt" (to-store ./${"[].txt"})) true]
    [((builtins.getContext (to-store ./${"[].txt"})) != {}) true]
  ];
}
