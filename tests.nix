{
  lib,
  pkgs,
  ...
}: let
  flake-dir = ./.;
  pretty = lib.generators.toPretty {multiline = false;};
  modules = (import ./assembly.nix {inherit pkgs lib;}).modules;
in
  (lib.concatMap (module:
    lib.pipe (module.contents.tests or {}) [
      (lib.mapAttrsToList (name: test:
        if lib.length test != 2
        then throw "invalid test '${name}' at '${module.path}'; a test shout be an attribute of form [ 'value' 'expected' ]"
        else let
          got = lib.elemAt test 0;
          expected = lib.elemAt test 1;
        in
          if got == expected
          then []
          else [
            {
              inherit name;
              data = {
                source = lib.removePrefix (toString flake-dir + "/") (toString module.path);
                expected = pretty expected;
                got = pretty got;
              };
            }
          ]))
      lib.concatLists
    ]))
  modules
