{utils, ...}: {
  merge-with-resolvers = resolvers:
    utils.attrs.merge-with
    (utils.compose resolvers);
}
