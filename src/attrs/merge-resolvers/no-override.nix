{utils, ...}: rec {
  base.no-override = name: lhs: rhs: let
    format = value:
      utils.string.apply-to-lines
      (line: "  ${line}")
      (utils.string.pretty value);
  in
    # -- do not remove the empty line
    throw
    ''

      there is a collision at '${name}' between

      ${format lhs}

      and

      ${format rhs}

      in attrset merge
    '';
  tests = [
    [(builtins.tryEval (base.no-override "_" {a = 1;} {a = 2;})).success false]
  ];
}
