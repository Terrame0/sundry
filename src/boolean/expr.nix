{sundry, ...}: rec {
  expr = fn: bound:
    fn (sundry.attrs.walk (_: fn: fn bound) sundry.boolean.operands);
  tests = let
    tag-set = {
      a = "1";
      b = ["1" "2"];
    };
  in [
    [(expr (o: o.tag {a = "1";}) tag-set) true]
    [(expr (o: o.tag {b = "2";}) tag-set) true]
    [(expr (o: o.tag {a = "9";}) tag-set) false]
    [(expr (o: o.tag {c = "1";}) tag-set) false]
    [(expr (o: o.tag {a = [];}) tag-set) true]
    [(expr (o: o.tag {c = [];}) tag-set) false]
    [(expr (o: o.tag ({a = "1";} // {b = "9";})) tag-set) false]
    [(expr (o: o.tag {b = ["9" "2"];}) tag-set) true]
    [(expr (o: with o; !(tag {c = [];})) tag-set) true]
    [(expr (o: with o; !(tag {a = [];})) tag-set) false]
    [(expr (o: with o; (tag {a = "9";}) || (tag {b = "1";})) tag-set) true]
    [(expr (o: with o; (tag {a = "9";}) || (tag {c = [];})) tag-set) false]
  ];
}
