{
  sundry,
  lib,
  ...
}: rec {
  before = sep: string:
    lib.head (sundry.str.split sep string);

  tests = {
    delimiter-present = [(before "." "A.B") "A"];
    multi-char-prefix = [(before "." "AB.C") "AB"];
    no-delimiter = [(before "." "A") "A"];
  };
}
