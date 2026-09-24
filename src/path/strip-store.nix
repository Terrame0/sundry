{
  lib,
  sundry,
  ...
}: rec {
  strip-store = value: let
    path-str = toString value;
  in
    if !(lib.isPath value || lib.isString value)
    then throw "strip-store: expected a path or a string, got a '${builtins.typeOf value}'"
    else if !(lib.hasPrefix builtins.storeDir path-str)
    then throw "strip-store: expected a path under '${builtins.storeDir}', got '${path-str}'"
    else lib.removePrefix (sundry.path.store-root path-str) path-str;
  tests = [
    [(strip-store "${builtins.storeDir}/abc-x/src/f.nix") "/src/f.nix"]
    [(strip-store "${builtins.storeDir}/abc-x") ""]
    [(sundry.does-throw (strip-store "/tmp/A.txt")) true]
    [(sundry.does-throw (strip-store 10)) true]
  ];
}
