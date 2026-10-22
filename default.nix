args: let
  pkgs =
    if args ? pkgs
    then args.pkgs
    else abort "'pkgs' missing; pass 'pkgs' to the library import statement";
  lib =
    if args ? pkgs
    then args.pkgs.lib
    else if args ? lib
    then args.lib
    else abort "'lib' missing; pass 'pkgs' or 'lib' to the library import statement";
in
  (import ./assembly.nix {inherit pkgs lib;}).sundry
