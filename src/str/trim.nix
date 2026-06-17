{lib, ...}: let
  trim-base = cond-fn: rm-fn: seq: str:
    if cond-fn seq str
    then trim-base cond-fn rm-fn seq (rm-fn seq str)
    else str;
in rec {
  trim-left = trim-base lib.hasPrefix lib.removePrefix;
  trim-right = trim-base lib.hasSuffix lib.removeSuffix;
  trim =
    trim-base
    (seq: str: lib.hasSuffix seq str || lib.hasPrefix seq str)
    (seq: str:
      lib.pipe str [
        (lib.removeSuffix seq)
        (lib.removePrefix seq)
      ]);
  tests = [
    [(trim "/" "////A//") "A"]
    [(trim-left "/" "////A//") "A//"]
    [(trim-right "/" "////A//") "////A"]
    [(trim "/" "") ""]
    [(trim "/" "ABC") "ABC"]
  ];
}
