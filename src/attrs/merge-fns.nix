{
  sundry,
  lib,
  ...
}: {
  merge = let
    resolvers = lib.attrsToList (removeAttrs sundry.attrs.merge-resolvers ["base"]);
    bases = lib.attrsToList sundry.attrs.merge-resolvers.base;
    resolver-permutations =
      lib.concatMap
      (i: (sundry.list.permutations resolvers i))
      (lib.genList (i: i) (lib.length resolvers + 1));
    product =
      map
      (list: lib.flatten list)
      (sundry.list.product resolver-permutations bases);
    fns =
      map
      (list:
        lib.setAttrByPath
        (map (attrs: attrs.name) list)
        (sundry.attrs.merge-with-resolvers (map (attrs: attrs.value) list)))
      product;
  in
    sundry.attrs.merge-with-resolvers
    (with sundry.attrs.merge-resolvers; [recursive no-collision])
    fns;
}
