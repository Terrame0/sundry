{
  mlem,
  lib,
  ...
}: rec {
  strip-between = lsep: rsep:
    map (path: "${lib.concatStrings (mlem.str.outside lsep rsep path)}");
  tests = [[(strip-between "<" ">" ["a<x>" "b<y>" "c<z>"]) ["a" "b" "c"]]];
}
