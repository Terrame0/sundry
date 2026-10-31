{sundry, ...}: rec {
  strip-between = lsep: rsep:
    map (path: "${sundry.str.join (sundry.str.outside lsep rsep path)}");

  tests = {
    strips-between = [(strip-between "<" ">" ["A<X>" "B<Y>" "C<Z>"]) ["A" "B" "C"]];
    keeps-unmarked = [(strip-between "<" ">" ["NOMARKER" "A<X>"]) ["NOMARKER" "A"]];
    nested-markers = [(strip-between "<" ">" ["A<B<C>D>E"]) ["AE"]];
  };
}
