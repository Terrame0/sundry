{
  description = "a nixos utility library";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };
  outputs = {
    nixpkgs,
    self,
    ...
  }: let
    evaluate = {system}: let
      pkgs = import nixpkgs {inherit system;};
      lib = pkgs.lib;
      args = {
        inherit lib;
        inherit pkgs;
        inherit utils;
        flake-root = self.outPath;
      };
      utils = import ./core/glob-functions.nix args;
      test-results = import ./core/check-tests.nix args;
    in {
      functions = utils;
      meta = {inherit test-results;};
    };
  in {result = evaluate {system = "x86_64-linux";};};
}
