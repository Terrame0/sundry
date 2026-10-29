{
  sundry,
  fixtures-dir,
  lib,
  ...
}: {
  reform =
    sundry.attrs.reform-until
    sundry.vfs.node.halt;

  reform-within-tag = expr-fn:
    sundry.attrs.reform-matched-until
    (path: node: sundry.boolean.expr expr-fn node.tag-list)
    sundry.vfs.node.halt;

  tests = let
    fixture-tree = sundry.vfs.tree.from-src (fixtures-dir + "/vfs-test-dir/test-files");
    tags-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.tree.from-src
      sundry.vfs.tree.resolve-tags
    ];
  in {
    reformed-fixture = [
      (sundry.vfs.tree.reform (path: node: {
          path = [(lib.last path)];
          value = {
            path = sundry.vfs.path.get.str path;
            text = "reformed ${sundry.vfs.file.read node}";
          };
        })
        fixture-tree)
      {
        "A.txt" = {
          text = "reformed contents of A.txt";
          path = "A.txt";
        };
        "B.txt" = {
          text = "reformed contents of B.txt";
          path = "B.txt";
        };
        "C.txt" = {
          text = "reformed contents of C.txt";
          path = "=/C.txt";
        };
      }
    ];
    within-tag = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.reform-within-tag
          (e: with e; tag {b = "1";})
          (path: node: {
            path = [(lib.last path)];
            value = node // {text = "reformed ${sundry.vfs.file.read node}";};
          })
          tags-tree))
      [
        "contents of F"
        "contents of A"
        "contents of B"
        "reformed contents of C"
        "contents of D"
        "contents of E"
        "reformed contents of G"
        "reformed contents of H"
        "reformed contents of I"
      ]
    ];
    malformed-leaf = [
      (sundry.does-throw
        (sundry.vfs.tree.reform
          (path: node: {
            path = [(lib.last path)];
            value = node;
          })
          {A = {junk = "abc";};}))
      true
    ];
  };
}
