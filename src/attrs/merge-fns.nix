{
  sundry,
  lib,
  ...
}: {
  merge = let
    resolvers = lib.attrsToList (removeAttrs sundry.attrs.merge-resolvers ["base"]);
    bases = lib.attrsToList sundry.attrs.merge-resolvers.base;
  in
    lib.pipe resolvers [
      (resolvers:
        lib.concatMap
        (i: sundry.list.permutations i resolvers)
        (sundry.range [(lib.length resolvers + 1)]))
      (permutations: sundry.list.product permutations bases)
      (map lib.flatten)
      (map (list:
        lib.setAttrByPath
        (map (attrs: attrs.name) list)
        (sundry.attrs.merge-with-resolvers (map (attrs: attrs.value) list))))
      (sundry.attrs.merge-with-resolvers
        (with sundry.attrs.merge-resolvers; [recursive no-collision]))
    ];
}
