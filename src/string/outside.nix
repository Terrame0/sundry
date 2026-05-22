{
  utils,
  lib,
  ...
}: rec {
  outside = lsep: rsep: str: let
    outsides = (utils.string.delimit lsep rsep str).outside;
  in
    lib.concatStrings (map (entry: entry.substr) outsides);
  tests = [[(outside "[" "]" "[a]bcd[ef]gh[i]") "bcdgh"]];
}
