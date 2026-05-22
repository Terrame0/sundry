{utils, ...}: {
  merge-recursive = utils.attrs.merge-recursive-with (lhs: rhs: rhs);
}
