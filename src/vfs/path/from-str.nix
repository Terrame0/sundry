{
  lib,
  mlem,
  ...
}: rec {
  from-str = path-str:
    lib.splitString "/"
    (mlem.str.trim-left "/"
      (builtins.unsafeDiscardStringContext (toString path-str)));
  tests = [
    [
      (from-str "/abc/def/ghi.txt")
      ["abc" "def" "ghi.txt"]
    ]
  ];
}
