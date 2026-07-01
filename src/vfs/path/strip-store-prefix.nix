{
  sundry,
  lib,
  ...
}: rec {
  #strip-store-prefix = path: let
  #  prefix = sundry.vfs.path.from-str builtins.storeDir;
  #  take-prefix = lib.sublist 0 (lib.length prefix);
  #  error-stem = "the path ${lib.generators.toPretty {multiline = false;} path}";
  #in
  #  if take-prefix path != prefix
  #  then throw "${error-stem} does not have a store prefix"
  #  else if !lib.isStorePath (sundry.debug ("/" + sundry.vfs.path.get.str path))
  #  then throw "${error-stem} is not a store path"
  #  else prefix;
  #tests = [[(strip-store-prefix ["nix" "store" "kh62p9ppffkdfgjynrcyi2biywkmwjdw-source"])]];
}
