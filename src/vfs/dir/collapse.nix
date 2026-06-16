{
  mlem,
  flake-root,
  lib,
  ...
}: rec {
  collapse = lib.mapAttrsToListRecursiveCond (_: attrs: !(mlem.vfs.is-leaf _ attrs));
  tests = [
    [
      (collapse
        (path: file: file.contents)
        (mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files"))
      ["contents of a.txt" "contents of b.txt" "contents of c.txt"]
    ]
  ];
}
