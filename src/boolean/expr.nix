{sundry, ...}: rec {
  expr = fn: bound:
    fn (sundry.attrs.walk (_: fn: fn bound) sundry.boolean.operands);
  tests = let
    tag-list = [{a = "1";} {b = ["1" "2"];}];
  in {
    tag-exact-match = [(expr (o: o.tag {a = "1";}) tag-list) true];
    tag-list-contains = [(expr (o: o.tag {b = "2";}) tag-list) true];
    tag-miss = [(expr (o: o.tag {a = "9";}) tag-list) false];
    tag-absent = [(expr (o: o.tag {c = "1";}) tag-list) false];
    tag-empty-spec = [(expr (o: o.tag {a = [];}) tag-list) true];
    tag-empty-spec-absent = [(expr (o: o.tag {c = [];}) tag-list) false];
    tag-partial-match = [(expr (o: o.tag ({a = "1";} // {b = "9";})) tag-list) false];
    tag-list-overlap = [(expr (o: o.tag {b = ["9" "2"];}) tag-list) true];
    negated-empty-spec = [(expr (o: with o; !(tag {c = [];})) tag-list) true];
    negated-empty-spec-match = [(expr (o: with o; !(tag {a = [];})) tag-list) false];
    or-second-match = [(expr (o: with o; (tag {a = "9";}) || (tag {b = "1";})) tag-list) true];
    or-no-match = [(expr (o: with o; (tag {a = "9";}) || (tag {c = [];})) tag-list) false];
  };
}
