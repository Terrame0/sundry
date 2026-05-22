{
  lib,
  utils,
  ...
}: rec {
  to-attrs = path-str: rec {
    path =
      lib.splitString "/"
      (utils.string.trim-left "/"
        (builtins.unsafeDiscardStringContext (toString path-str)));
    leaf = let
      leaf = lib.last path;
      leaf-parts = lib.splitString "." leaf;
    in {
      full = leaf;
      stem =
        lib.concatStringsSep "."
        (utils.list.incl-init leaf-parts);
      ext = utils.if-null (utils.list.excl-last leaf-parts) "";
    };
  };
  tests = [
    [
      (to-attrs "/abc/def/ghi.txt")
      {
        leaf = {
          ext = "txt";
          full = "ghi.txt";
          stem = "ghi";
        };
        path = [
          "abc"
          "def"
          "ghi.txt"
        ];
      }
    ]
  ];
}
