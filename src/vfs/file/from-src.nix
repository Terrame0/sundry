{
  sundry,
  lib,
  fixtures-dir,
  ...
}: rec {
  from-src = vfs-path: fs-path:
    if vfs-path == []
    then throw "cannot create a valid vfs node with an empty path"
    else let
      type = builtins.readFileType fs-path;
    in
      if type == "regular"
      then lib.setAttrByPath vfs-path {origin = fs-path;}
      else throw "vfs.file.from-src: ${sundry.str.pretty vfs-path} entry is of unsupported type '${type}'";
  tests = {
    nested-path = [
      (from-src ["abc" "def" "A.txt"] (fixtures-dir + "/vfs-test-dir/test-files/A.txt"))
      {
        abc = {
          def = {
            "A.txt" = {
              origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";
            };
          };
        };
      }
    ];
    opaque = [((from-src ["A.txt"] (fixtures-dir + "/vfs-test-dir/test-files/A.txt"))."A.txt" ? text) false];
    does-not-read = [(sundry.does-throw (from-src ["A"] (fixtures-dir + "/vfs-test-dir/binary/A"))) false];
    throws-on-empty-path = [(sundry.does-throw (from-src [] (fixtures-dir + "/vfs-test-dir/test-files/A.txt"))) true];
    throws-on-symlink = [(sundry.does-throw (from-src ["B"] (fixtures-dir + "/vfs-test-dir/symlinks/B"))) true];
    throws-on-directory = [(sundry.does-throw (from-src ["A"] (fixtures-dir + "/vfs-test-dir/test-files"))) true];
    path-origin = [(lib.isPath (from-src ["A.txt"] (fixtures-dir + "/vfs-test-dir/test-files/A.txt"))."A.txt".origin) true];
    string-origin = [(lib.isString (from-src ["A.txt"] (toString (fixtures-dir + "/vfs-test-dir/test-files/A.txt")))."A.txt".origin) true];
  };
}
