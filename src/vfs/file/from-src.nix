{
  sundry,
  lib,
  fixtures-dir,
  ...
}: rec {
  from-src = vfs-path: fs-path:
    sundry.attrs.merge.recursive.no-collision [
      (sundry.vfs.file.from-text vfs-path (builtins.readFile fs-path))
      (lib.setAttrByPath vfs-path {origin = fs-path;})
    ];
  tests = {
    nested-path = [
      (from-src ["abc" "def" "A.txt"] (fixtures-dir + "/vfs-test-dir/test-files/A.txt"))
      {
        abc = {
          def = {
            "A.txt" = {
              text = "contents of A.txt";
              origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";
            };
          };
        };
      }
    ];
    throws-on-empty-path = [(sundry.does-throw (from-src [] (fixtures-dir + "/vfs-test-dir/test-files/A.txt"))) true];
    does-not-force-directory = [(sundry.does-throw-whnf (from-src ["A"] (fixtures-dir + "/vfs-test-dir/test-files"))) false];
    path-origin = [(lib.isPath (from-src ["A.txt"] (fixtures-dir + "/vfs-test-dir/test-files/A.txt"))."A.txt".origin) true];
    string-origin = [(lib.isString (from-src ["A.txt"] "${toString fixtures-dir}/vfs-test-dir/test-files/A.txt")."A.txt".origin) true];
  };
}
