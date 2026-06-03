{
  lib,
  mlem,
  ...
}: rec {
  to-attrs = path-str: rec {
    path =
      lib.splitString "/"
      (mlem.string.trim-left "/"
        (builtins.unsafeDiscardStringContext (toString path-str)));
    leaf = let
      leaf = lib.last path;
      leaf-parts = lib.splitString "." leaf;
    in {
      full = leaf;
      stem =
        lib.concatStringsSep "."
        (mlem.list.incl-init leaf-parts);
      ext = mlem.if-null (mlem.list.excl-last leaf-parts) "";
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
