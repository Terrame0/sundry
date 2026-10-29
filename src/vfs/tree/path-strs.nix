{
  sundry,
  fixtures-dir,
  ...
}: rec {
  path-strs = tree:
    sundry.vfs.tree.collapse
    (path: _: sundry.vfs.path.get.str path)
    tree;
  tests = {
    tagged-tree = [
      (path-strs (sundry.vfs.tree.from-src (fixtures-dir + "/vfs-test-dir/test-files")))
      [
        "=/C.txt"
        "A.txt"
        "B.txt"
      ]
    ];
    throws-on-invalid = [
      (sundry.does-throw (path-strs {
        invalid = "abc";
      }))
      true
    ];
    lazy-expr = [
      (path-strs {
        A = {
          origin = "/A";
          expr = throw "expr was forced";
        };
      })
      ["A"]
    ];
  };
}
