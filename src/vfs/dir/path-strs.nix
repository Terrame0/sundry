{
  sundry,
  fixtures-dir,
  ...
}: rec {
  path-strs = dir:
    sundry.vfs.dir.collapse
    (path: _: sundry.vfs.path.get.str path)
    dir;
  tests = {
    tagged-tree = [
      (path-strs (sundry.vfs.dir.from-src (fixtures-dir + "/vfs-test-dir/test-files")))
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
  };
}
