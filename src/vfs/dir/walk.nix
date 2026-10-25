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
    fixture-file-tree = sundry.vfs.dir.from-src (fixtures-dir + "/vfs-test-dir/test-files");
    tags-file-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.dir.from-src
      sundry.vfs.dir.resolve-tags
    ];
  in {
    walked-tree = [
      (sundry.vfs.dir.walk (path: node: {text = "walked ${node.text}";}) fixture-file-tree)
      {
        "A.txt" = {text = "walked contents of A.txt";};
        "B.txt" = {text = "walked contents of B.txt";};
        "=" = {"C.txt" = {text = "walked contents of C.txt";};};
      }
    ];
    within-tag = [
      (sundry.vfs.dir.collapse
        (path: node: node.text)
        (sundry.vfs.dir.walk-within-tag
          (e: with e; tag {b = "1";})
          (path: node: node // {text = "walked ${node.text}";})
          tags-file-tree))
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
        (sundry.vfs.dir.walk
          (path: node: {text = "walked ${node.text}";})
          {A = {junk = "abc";};}))
      true
    ];
  };
}
