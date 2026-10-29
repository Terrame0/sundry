{
  sundry,
  fixtures-dir,
  lib,
  ...
}: {
  select-by-tag = expr-fn:
    sundry.vfs.tree.filter
    (path: node: sundry.boolean.expr expr-fn node.tag-list);

  tests = let
    tags-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.tree.from-src
      sundry.vfs.tree.resolve-tags
    ];
  in {
    match-tag-b = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.select-by-tag
          (e: with e; tag {b = "1";})
          tags-tree))
      ["contents of H" "contents of G" "contents of I" "contents of C"]
    ];
    exclude-tag-b = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.select-by-tag
          (e: with e; !(tag {b = [];}))
          tags-tree))
      ["contents of F" "contents of A" "contents of B" "contents of E"]
    ];
    match-or-exclude = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.select-by-tag
          (e: with e; (tag {b = "1";}) || !(tag {b = [];}))
          tags-tree))
      [
        "contents of H"
        "contents of G"
        "contents of F"
        "contents of I"
        "contents of A"
        "contents of B"
        "contents of C"
        "contents of E"
      ]
    ];
  };
}
