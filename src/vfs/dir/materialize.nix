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
    mlem.vfs.dir.collapse (path: file: mlem.vfs.path.get.str ([base-path] ++ path)) dir;
  tests = [
    [
      (lib.pipe "${flake-root}/tests/vfs-test-dir/test-files" [
        mlem.vfs.dir.from-src
        (materialize "test-dir")
        lib.head
        builtins.readFile
      ])
      "contents of a.txt"
    ]
  ];
}
