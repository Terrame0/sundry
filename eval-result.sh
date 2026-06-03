nix eval --impure --raw --show-trace --expr '
let
  flake = builtins.getFlake (toString ./.);
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
in
  pkgs.lib.generators.toPretty {} (flake.outputs.evaluate { system = "x86_64-linux"; })
'
echo