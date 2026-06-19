{sundry, ...}: {
  merge-with-resolvers = resolvers:
    sundry.attrs.merge-with
    (sundry.compose resolvers);
}
