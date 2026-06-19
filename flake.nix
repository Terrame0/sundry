{
  description = "a nixos utility library";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };
  outputs = {
    nixpkgs,
    self,
    ...
  }: {
    evaluate = {system}: let
      pkgs = import nixpkgs {inherit system;};
      lib = pkgs.lib;
      args = {
        inherit lib;
        inherit pkgs;
        inherit sundry;
        flake-root = self.outPath;
      };
      sundry = import ./core/glob-functions.nix args;
      test-results = import ./core/check-tests.nix args;
    in {
      functions = sundry;
      meta = {inherit test-results;};
    };
  };
}
