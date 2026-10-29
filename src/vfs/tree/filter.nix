{
  sundry,
  fixtures-dir,
  lib,
  ...
}: {
  filter =
    sundry.attrs.filter-until
    sundry.vfs.node.halt;

  filter-within-tag = expr-fn:
    sundry.attrs.filter-matched-until
    (path: node: sundry.boolean.expr expr-fn node.tag-list)
    sundry.vfs.node.halt;

  tests = let
    filtering-tree = sundry.vfs.tree.from-src (fixtures-dir + "/vfs-test-dir/filtering");
    tags-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.tree.from-src
      sundry.vfs.tree.resolve-tags
    ];
  in {
    by-ext-or-text = [
      (lib.pipe filtering-tree [
        (sundry.vfs.tree.filter (path: node:
          sundry.vfs.path.get.ext path
          == "txt"
          || sundry.vfs.file.read node
          == "override"))
        sundry.vfs.tree.path-strs
      ])
      [
        "=/=/E.ini"
        "=/=/G.txt"
        "=/C.txt"
        "A.txt"
        "B.txt"
      ]
    ];
    tag-b1-all = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.filter-within-tag
          (e: with e; tag {b = "1";})
          (path: node: false)
          tags-tree))
      [
        "contents of F"
        "contents of A"
        "contents of B"
        "contents of D"
        "contents of E"
      ]
    ];
    tag-b1-exclude-h = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.filter-within-tag
          (e: with e; tag {b = "1";})
          (path: node: sundry.vfs.file.read node != "contents of H")
          tags-tree))
      [
        "contents of G"
        "contents of F"
        "contents of I"
        "contents of A"
        "contents of B"
        "contents of C"
        "contents of D"
        "contents of E"
      ]
    ];
    tag-a1-all = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.filter-within-tag
          (e: with e; tag {a = "1";})
          (path: node: false)
          tags-tree))
      [
        "contents of I"
        "contents of B"
        "contents of D"
        "contents of E"
      ]
    ];
    malformed-leaf = [
      (sundry.does-throw
        (sundry.vfs.tree.filter (path: node: true) {A = {junk = "abc";};}))
      true
    ];
  };
}
