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
  in
    pkgs.runCommand drv-name {} cmd;
  tests = [
    [
      (builtins.readFile
        "${materialize "test-dir" (mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/test-files")}/a.txt")
      "contents of a.txt"
    ]
  ];
}
