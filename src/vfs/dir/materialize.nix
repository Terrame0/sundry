{
  lib,
  mlem,
  flake-root,
  pkgs,
  ...
}: rec {
  materialize = drv-name: dir: let
    files =
      mlem.attrs.collapse-until
      mlem.vfs.is-leaf
      (path: attrs: {
        inherit path;
        inherit (attrs) contents;
      })
      dir;
    cmd =
      lib.foldl (
        cmd-acc: file-attrs: let
          dir = lib.concatStringsSep "/" (lib.init file-attrs.path);
          file-path = lib.concatStringsSep "/" file-attrs.path;
          mk-dir-cmd = "mkdir -p $out/${dir} \n";
          cp-file-cmd = "printf '%s' '${builtins.replaceStrings ["'"] ["'\\''"] file-attrs.contents}' > $out/${file-path} \n";
        in
          cmd-acc + mk-dir-cmd + cp-file-cmd
      ) ""
      files;
    base-path = pkgs.runCommand drv-name {} cmd;
  in
    mlem.vfs.dir.walk
    (path: file: rec {
      src = mlem.vfs.path.get.str [base rel];
      base = base-path;
      rel = mlem.vfs.path.get.str path;
    })
    dir;

  tests = [
    [
      (builtins.readFile
        (lib.pipe "${flake-root}/tests/vfs-test-dir/test-files" [
          mlem.vfs.dir.from-src
          (materialize "test-dir")
        ])."A.txt".src)
      "contents of A.txt"
    ]
  ];
}
