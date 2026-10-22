{sundry, ...}: rec {
  to-segments = sep: string:
    if string == ""
    then []
    else sundry.str.split sep string;

  tests = {
    multiple-segments = [(to-segments "/" "A/B/C") ["A" "B" "C"]];
    single-segment = [(to-segments "/" "A") ["A"]];
    empty-string = [(to-segments "/" "") []];
  };
}
