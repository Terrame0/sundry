{
  sundry,
  lib,
  ...
}: rec {
  at = i: str: let
    len = sundry.str.len str;
  in
    if i >= 0 && i < len
    then lib.substring i 1 str
    else if i < 0 && i >= (-len)
    then lib.substring (len + i) 1 str
    else throw "index '${toString i}' out of range, expected values '0..${toString (len - 1)}' or '-1..${toString (-len)}'";
  tests = [
    [(at 0 "abc") "a"]
    [(at 2 "abc") "c"]
    [(at (-3) "abc") "a"]
    [(at (-1) "abc") "c"]
    [(sundry.does-throw (at 5 "abc")) true]
    [(sundry.does-throw (at (-4) "abc")) true]
  ];
}
