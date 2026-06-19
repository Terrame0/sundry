{sundry, ...}: rec {
  outside = lsep: rsep: str:
    map (entry: entry.substr)
    (sundry.str.delimit lsep rsep str).outside;
  tests = [
    [(outside "[" "]" "[A]BCD[EF]GH[I]") ["" "BCD" "GH" ""]]
    [(outside "[" "]" "ABC") ["ABC"]]
    [(outside "[" "]" "") [""]]
  ];
}
