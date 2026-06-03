{mlem, ...}: {
  merge-with-resolvers = resolvers:
    mlem.attrs.merge-with
    (mlem.compose resolvers);
}
