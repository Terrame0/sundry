{sundry, ...}: rec {
  from-str = path-str:
    sundry.str.to-segments "/"
    (sundry.str.trim-left "/"
      # -- segments become attribute names, which forbid store context
      # - toString keeps that context when the input is already a context-carrying string
      # - so we discard to accept both path literals and "${flake-root}/..." strings
      (builtins.unsafeDiscardStringContext (toString path-str)));
  tests = [
    [
      (from-str "/A/B/C.txt")
      ["A" "B" "C.txt"]
    ]
    [(from-str "A/B") ["A" "B"]]
    [(from-str "") []]
  ];
}
