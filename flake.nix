{
  description = "a nix utility library";
  inputs = {};
  outputs = {...}: {
    tests = import ./tests.nix;
  };
}
