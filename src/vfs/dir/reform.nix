{
  sundry,
  fixtures-dir,
  lib,
  ...
}: {
  reform =
    sundry.attrs.reform-until
    sundry.vfs.is-leaf-node;

  reform-within-tag = expr-fn:
    sundry.attrs.reform-matched-until
    (path: file: sundry.boolean.expr expr-fn file.tag-list)
    sundry.vfs.is-leaf-node;

  tests = let
    fixture-file-tree = sundry.vfs.dir.from-src (fixtures-dir + "/vfs-test-dir/test-files");
    tags-file-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.dir.from-src
      sundry.vfs.dir.resolve-tags
    ];
  in {
    reformed-fixture = [
      (sundry.vfs.dir.reform (path: file: {
          path = [(lib.last path)];
          value = {
            path = sundry.vfs.path.get.str path;
            text = "reformed ${file.text}";
          };
        })
        fixture-file-tree)
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
      (sundry.vfs.dir.collapse
        (path: file: file.text)
        (sundry.vfs.dir.reform-within-tag
          (e: with e; tag {b = "1";})
          (path: file: {
            path = [(lib.last path)];
            value = file // {text = "reformed ${file.text}";};
          })
          tags-file-tree))
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
  };
}
