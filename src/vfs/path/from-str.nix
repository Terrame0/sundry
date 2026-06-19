{
  lib,
  sundry,
  ...
}: rec {
  from-str = path-str:
    lib.splitString "/"
    (sundry.str.trim-left "/"
      (builtins.unsafeDiscardStringContext (toString path-str)));
  tests = [
    [
      (from-str "/A/B/C.txt")
      ["A" "B" "C.txt"]
    ]
    [(from-str "A/B") ["A" "B"]]
  ];
}
