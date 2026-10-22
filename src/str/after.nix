{
  sundry,
  lib,
  ...
}: rec {
  after = sep: string:
    sundry.str.join-with sep (lib.tail (sundry.str.split sep string));

  tests = {
    single-dot = [(after "." "A.B") "B"];
    multiple-dots = [(after "." "A.B.C") "B.C"];
    no-delimiter = [(after "." "A") ""];
  };
}
