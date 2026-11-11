{
  sundry,
  lib,
  fixtures-dir,
  ...
}: rec {
  from-src = dir-path:
    lib.pipe dir-path [
      lib.filesystem.listFilesRecursive
      (map (fs-path: let
        type = builtins.readFileType fs-path;
      in
        if type == "regular"
        then
          sundry.vfs.file.from-src
          (lib.drop
            (lib.length (sundry.vfs.path.from-str dir-path))
            (sundry.vfs.path.from-str fs-path))
          fs-path
        else
          lib.warn
          "vfs.tree.from-src: skipping file '${fs-path}' of unsupported type '${type}'"
          {}))
      sundry.attrs.merge.recursive.no-collision
    ];

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
    origin-is-path = [(lib.isPath (from-src (fixtures-dir + "/vfs-test-dir/test-files"))."A.txt".origin) true];
    origin-is-string = [(lib.isString (from-src "${toString fixtures-dir}/vfs-test-dir/test-files")."A.txt".origin) true];
    ignores-symlink = [(lib.hasAttrByPath ["B"] (from-src (fixtures-dir + "/vfs-test-dir/symlinks"))) false];
  };
}
