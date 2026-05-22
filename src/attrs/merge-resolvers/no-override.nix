{utils, ...}: {
  no-override = lhs: rhs: let
    format = value:
      utils.string.apply-to-lines
      (line: " - ${line}")
      (utils.string.pretty value);
  in
    # -- do not remove the empty line
    throw
    ''

      there is a collision between
      ${format lhs}
      and
      ${format rhs}
      in attrset merge
    '';
}
