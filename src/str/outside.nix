{sundry, ...}: rec {
  outside = lsep: rsep: str:
    map (entry: entry.substr)
    (sundry.str.delimit lsep rsep str).outside;
  tests = {
    text-between = [(outside "[" "]" "[A]BCD[EF]GH[I]") ["" "BCD" "GH" ""]];
    no-delimiters = [(outside "[" "]" "ABC") ["ABC"]];
    empty-string = [(outside "[" "]" "") [""]];
  };
}
