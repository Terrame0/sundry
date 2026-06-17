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
      (from-str "/A/B/C.txt")
      ["A" "B" "C.txt"]
    ]
    [(from-str "A/B") ["A" "B"]]
  ];
}
