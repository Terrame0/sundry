{
  sundry,
  fixtures-dir,
  lib,
  ...
}: {
  select-by-tag = expr-fn:
    sundry.vfs.dir.filter
    (path: file: sundry.boolean.expr expr-fn file.tag-list);

  tests = let
    tags-file-tree = lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
      sundry.vfs.dir.from-src
      sundry.vfs.dir.resolve-tags
    ];
  in {
    match-tag-b = [
      (sundry.vfs.dir.collapse
        (path: file: file.text)
        (sundry.vfs.dir.select-by-tag
          (e: with e; tag {b = "1";})
          tags-file-tree))
      ["contents of H" "contents of G" "contents of I" "contents of C"]
    ];
    exclude-tag-b = [
      (sundry.vfs.dir.collapse
        (path: file: file.text)
        (sundry.vfs.dir.select-by-tag
          (e: with e; !(tag {b = [];}))
          tags-file-tree))
      ["contents of F" "contents of A" "contents of B" "contents of E"]
    ];
    match-or-exclude = [
      (sundry.vfs.dir.collapse
        (path: file: file.text)
        (sundry.vfs.dir.select-by-tag
          (e: with e; (tag {b = "1";}) || !(tag {b = [];}))
          tags-file-tree))
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
