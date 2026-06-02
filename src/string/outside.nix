{utils, ...}: rec {
  outside = lsep: rsep: str:
    map (entry: entry.substr)
    (utils.string.delimit lsep rsep str).outside;
  tests = [[(outside "[" "]" "[a]bcd[ef]gh[i]") ["" "bcd" "gh" ""]]];
}
