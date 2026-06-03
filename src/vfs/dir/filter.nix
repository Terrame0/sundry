{mlem, ...}: {
  filter =
    mlem.attrs.filter-until
    (path: mlem.vfs.is-leaf);
}
