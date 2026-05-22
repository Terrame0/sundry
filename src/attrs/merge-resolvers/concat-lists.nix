{lib, ...}: {
  concat-lists = default: lhs: rhs:
    if lib.isList lhs && lib.isList rhs
    then lhs ++ rhs
    else default lhs rhs;
}
