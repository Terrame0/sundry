{
  lib,
  pkgs,
}: let
  flake-dir = ./.;
  fixtures-dir = ./test-fixtures;
  bootstrap = import ./bootstrap {inherit lib;};
in rec {
  modules = lib.pipe (flake-dir + "/src") [
    lib.filesystem.listFilesRecursive
    # -- baseNameOf is required to avoid store coercion inside hasSuffix
    # - (that will break on invalid file names)
    (lib.filter (path: lib.hasSuffix ".nix" (baseNameOf path)))
    (map (module-path: {
      path = module-path;
      contents = import module-path {
        inherit flake-dir fixtures-dir;
        inherit pkgs lib sundry;
      };
    }))
  ];
  sundry = lib.foldl (acc: module:
    lib.pipe module.contents [
      (lib.flip removeAttrs ["tests"])
      (lib.setAttrByPath (lib.pipe module.path [
        toString
        (lib.removeSuffix ".nix")
        (lib.removePrefix (toString flake-dir + "/src/"))
        (lib.splitString "/")
        lib.init
      ]))
      (bootstrap.merge-attrs-recursive acc)
    ]) {}
  modules;
}
