{
  lib,
  utils,
  flake-root,
  pkgs,
  ...
}: rec {
  materialize = dir: drv-name: let
    files = lib.collect (attrs: attrs ? path && attrs ? contents) (
      lib.mapAttrsRecursiveCond
      (attrs: !(attrs ? contents))
      (path: attrs: {
        inherit path;
        inherit (attrs) contents;
      })
      dir
    );
    cmd =
      lib.foldl (
        cmd-acc: file-attrs: let
          dir = lib.concatStringsSep "/" (lib.init file-attrs.path);
          file-path = lib.concatStringsSep "/" file-attrs.path;
          mk-dir-cmd = "mkdir -p $out/${dir} \n";
          cp-file-cmd = "printf '%s' '${file-attrs.contents}' > $out/${file-path} \n";
        in
          cmd-acc + mk-dir-cmd + cp-file-cmd
      ) ""
      files;
  in
    pkgs.runCommand drv-name {} cmd;
  tests = [
    [
      (builtins.readFile "${materialize
        (utils.dir.from-real "${flake-root}/tests/vfs-test-dir/test-files")
        "test-dir"}/test-files/a.txt")
      "contents of a.txt"
    ]
  ];
}
