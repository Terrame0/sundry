let expr = '
let
    nixpkgs = builtins.getFlake "nixpkgs";
    pkgs = import nixpkgs {};
in
    (import ./tests.nix) { inherit pkgs; inherit (pkgs) lib; }
'

^nix eval --impure --json --show-trace --expr $expr
| from json
| select name data
| update data { select source expected got }
| table --expand 
