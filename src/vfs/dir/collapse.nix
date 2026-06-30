{
  lib,
  sundry,
  flake-root,
  ...
}: {
  collapse =
    sundry.attrs.collapse-until
    sundry.vfs.is-leaf-node;

  collapse-by-tag = expr-fn:
    sundry.attrs.collapse-matched-until
    (path: file: sundry.boolean.expr expr-fn (sundry.attrs.merge.concat file.tag-list))
    sundry.vfs.is-leaf-node;

  tests = let
    test-dir = sundry.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files";
    tag-dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      sundry.vfs.dir.from-src
      (sundry.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (sundry.vfs.dir.collapse (path: file: file.text) test-dir)
      ["contents of C.txt" "contents of A.txt" "contents of B.txt"]
    ]
    [
      (sundry.vfs.dir.collapse-by-tag
        (e: with e; tag {b = "1";})
        (path: file: file.text)
        tag-dir)
      ["contents of H" "contents of G" "contents of I" "contents of C"]
    ]
    [
      (sundry.vfs.dir.collapse-by-tag
        (e: with e; !(tag {b = [];}))
        (path: file: file.text)
        tag-dir)
      ["contents of F" "contents of A" "contents of B" "contents of E"]
    ]
  ];
}
