{sundry, ...}: rec {
  from-str = path-str:
    sundry.vfs.path.validate
    (sundry.str.to-segments "/"
      (sundry.str.trim-left "/"
        # -- segments become attribute names that forbid store context
        (builtins.unsafeDiscardStringContext (toString path-str))));
  tests = {
    absolute-path = [(from-str "/A/B/C.txt") ["A" "B" "C.txt"]];
    relative-path = [(from-str "A/B") ["A" "B"]];
    empty-path = [(from-str "") []];
    throws-on-empty-segment = [(sundry.does-throw (from-str "A//B")) true];
    throws-on-trailing-slash = [(sundry.does-throw (from-str "A/")) true];
    throws-on-dot-segment = [(sundry.does-throw (from-str "A/./B")) true];
    throws-on-dot-dot-segment = [(sundry.does-throw (from-str "A/../B")) true];
  };
}
