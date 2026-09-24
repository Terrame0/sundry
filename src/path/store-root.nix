{lib, ...}: rec {
  store-root = path-str:
    lib.pipe path-str [
      (lib.splitString "/")
      (lib.take (lib.length (lib.splitString "/" builtins.storeDir) + 1))
      (lib.concatStringsSep "/")
    ];
  tests = [
    [(store-root "${builtins.storeDir}/abc-x/src/f.nix") "${builtins.storeDir}/abc-x"]
    [(store-root "${builtins.storeDir}/abc-x") "${builtins.storeDir}/abc-x"]
  ];
}
