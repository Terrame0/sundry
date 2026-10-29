{
  lib,
  sundry,
  fixtures-dir,
  ...
}: {
  walk =
    sundry.attrs.walk-until
    sundry.vfs.node.halt;

  walk-within-tag = expr-fn:
    sundry.attrs.walk-matched-until
    (path: node: sundry.boolean.expr expr-fn node.tag-list)
    sundry.vfs.node.halt;

  tests = let
    fixture-tree = sundry.vfs.tree.from-src (fixtures-dir + "/vfs-test-dir/test-files");
    tags-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.tree.from-src
      sundry.vfs.tree.resolve-tags
    ];
  in {
    walked-tree = [
      (sundry.vfs.tree.walk (path: node: {text = "walked ${sundry.vfs.file.read node}";}) fixture-tree)
      {
        "A.txt" = {text = "walked contents of A.txt";};
        "B.txt" = {text = "walked contents of B.txt";};
        "=" = {"C.txt" = {text = "walked contents of C.txt";};};
      }
    ];
    within-tag = [
      (sundry.vfs.tree.collapse
        (path: node: sundry.vfs.file.read node)
        (sundry.vfs.tree.walk-within-tag
          (e: with e; tag {b = "1";})
          (path: node: node // {text = "walked ${sundry.vfs.file.read node}";})
          tags-tree))
      [
        "walked contents of H"
        "walked contents of G"
        "contents of F"
        "walked contents of I"
        "contents of A"
        "contents of B"
        "walked contents of C"
        "contents of D"
        "contents of E"
      ]
    ];
    malformed-leaf = [
      (sundry.does-throw
        (sundry.vfs.tree.walk
          (path: node: {text = "walked ${sundry.vfs.file.read node}";})
          {A = {junk = "abc";};}))
      true
    ];
    preserves-empty-directory = [
      (sundry.vfs.tree.walk (path: node: node) {
        A = {};
        B = {text = "b";};
      })
      {
        A = {};
        B = {text = "b";};
      }
    ];
  };
}
