{
  utils,
  lib,
  ...
}: {
  merge = let
    resolvers = lib.attrsToList (removeAttrs utils.attrs.merge-resolvers ["base"]);
    bases = lib.attrsToList utils.attrs.merge-resolvers.base;
    resolver-permutations =
      lib.concatMap
      (i: (utils.list.permutations resolvers i))
      (lib.genList (i: i) (lib.length resolvers + 1));
    product =
      map
      (list: lib.flatten list)
      (utils.list.product resolver-permutations bases);
    fns =
      map
      (list:
        lib.setAttrByPath
        (map (attrs: attrs.name) list)
        (utils.attrs.merge-with-resolvers (map (attrs: attrs.value) list)))
      product;
  in
    utils.attrs.merge-with-resolvers
    (with utils.attrs.merge-resolvers; [recursive no-collision])
    fns;
}
