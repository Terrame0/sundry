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
        inherit mlem;
        flake-root = self.outPath;
      };
      mlem = import ./core/glob-functions.nix args;
      test-results = import ./core/check-tests.nix args;
    in {
      functions = mlem;
      meta = {inherit test-results;};
    };
  };
}
