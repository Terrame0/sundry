{
  sundry,
  fixtures-dir,
  lib,
  ...
}: {
  filter =
    sundry.attrs.filter-until
    sundry.vfs.is-leaf-node;

  filter-within-tag = expr-fn:
    sundry.attrs.filter-matched-until
    (path: file: sundry.boolean.expr expr-fn file.tag-list)
    sundry.vfs.is-leaf-node;

  tests = let
    filtering-file-tree = sundry.vfs.dir.from-src (fixtures-dir + "/vfs-test-dir/filtering");
    tags-file-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.dir.from-src
      sundry.vfs.dir.resolve-tags
    ];
  in {
    filter-by-ext-or-text = [
      (lib.pipe filtering-file-tree [
        (sundry.vfs.dir.filter (path: file:
          sundry.vfs.path.get.ext path
          == "txt"
          || file.text
          == "override"))
        sundry.vfs.dir.path-strs
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
      (sundry.vfs.dir.collapse
        (path: file: file.text)
        (sundry.vfs.dir.filter-within-tag
          (e: with e; tag {b = "1";})
          (path: file: false)
          tags-file-tree))
      [
        "contents of F"
        "contents of A"
        "contents of B"
        "contents of D"
        "contents of E"
      ]
    ];
    tag-b1-exclude-h = [
      (sundry.vfs.dir.collapse
        (path: file: file.text)
        (sundry.vfs.dir.filter-within-tag
          (e: with e; tag {b = "1";})
          (path: file: file.text != "contents of H")
          tags-file-tree))
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
      (sundry.vfs.dir.collapse
        (path: file: file.text)
        (sundry.vfs.dir.filter-within-tag
          (e: with e; tag {a = "1";})
          (path: file: false)
          tags-file-tree))
      [
        "contents of I"
        "contents of B"
        "contents of D"
        "contents of E"
      ]
    ];
  };
}
