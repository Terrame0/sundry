{
  sundry,
  lib,
  fixtures-dir,
  ...
}: rec {
  from-src = dir-path: let
    path-to-file = fs-path:
      sundry.vfs.file.from-src
      (lib.drop
        (lib.length (sundry.vfs.path.from-str dir-path))
        (sundry.vfs.path.from-str fs-path))
      fs-path;
  in
    sundry.attrs.merge.recursive.no-collision
    (map path-to-file (lib.filesystem.listFilesRecursive dir-path));

  tests = {
    tree = [
      (from-src (fixtures-dir + "/vfs-test-dir/test-files"))
      {
        "A.txt" = {
          origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";
        };
        "B.txt" = {
          origin = fixtures-dir + "/vfs-test-dir/test-files/B.txt";
        };
        "=" = {
          "C.txt" = {
            origin = fixtures-dir + "/vfs-test-dir/test-files/=/C.txt";
          };
        };
      }
    ];
    opaque = [((from-src (fixtures-dir + "/vfs-test-dir/test-files"))."A.txt" ? text) false];
    origin-is-path = [(lib.isPath (from-src (fixtures-dir + "/vfs-test-dir/test-files"))."A.txt".origin) true];
    origin-is-string = [(lib.isString (from-src "${toString fixtures-dir}/vfs-test-dir/test-files")."A.txt".origin) true];
    throws-on-symlink = [(sundry.does-throw (from-src (fixtures-dir + "/vfs-test-dir/symlinks"))) true];
  };
}
