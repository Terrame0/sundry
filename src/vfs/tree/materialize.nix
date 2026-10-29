{
  lib,
  sundry,
  fixtures-dir,
  pkgs,
  ...
}: rec {
  materialize = name: tree: let
    data = lib.pipe tree [
      (sundry.vfs.tree.collapse (path': node: let
        path = sundry.vfs.path.validate path';
      in {
        dir = sundry.vfs.path.get.str (lib.init path);
        file = sundry.vfs.path.get.basename path;
        src =
          if sundry.vfs.node.is-opaque path node
          then sundry.path.to-store-str node.origin
          else
            lib.pipe path [
              sundry.vfs.path.get.basename
              lib.strings.sanitizeDerivationName
              (lib.flip builtins.toFile node.text)
            ];
      }))
    ];
    script =
      # -< nu >-
      ''
        let attrs = open $env.NIX_ATTRS_JSON_FILE
        let out = $attrs.outputs.out
        mkdir $out
        for $entry in $attrs.data {
          mkdir ([$out $entry.dir] | path join)
          cp $entry.src ([$out $entry.dir $entry.file] | path join)
        }
      '';
    drv = derivation {
      inherit name;
      inherit (pkgs.stdenvNoCC.hostPlatform) system;
      __structuredAttrs = true;
      allowSubstitutes = false;
      builder = lib.getExe pkgs.nushell;
      inherit data;
      args = [(builtins.toFile "materialize.nu" script)];
    };
  in {
    inherit drv;
    tree =
      sundry.vfs.tree.reform
      (path: node: {
        inherit path;
        value =
          (removeAttrs node ["text" "expr"])
          // {
            origin = sundry.vfs.path.get.str ([drv] ++ path);
          };
      })
      tree;
  };

  tests = let
    fixture-tree = sundry.vfs.tree.from-src (fixtures-dir + "/vfs-test-dir/test-files");
    authored-tree =
      sundry.vfs.tree.merge
      fixture-tree
      (sundry.vfs.file.from-text ["=" "authored.txt"] "authored");
    result = materialize "test-dir" authored-tree;
    lazy-tree = {
      "A.txt" = {
        origin = "/tmp/A.txt";
        text = throw "text was forced";
      };
    };
  in {
    tree-origin-text = [
      (sundry.vfs.file.read result.tree."A.txt")
      "contents of A.txt"
    ];
    drv-path-text = [(builtins.readFile "${result.drv}/A.txt") "contents of A.txt"];
    authored-text = [(builtins.readFile "${result.drv}/=/authored.txt") "authored"];
    tree-drops-text = [((result.tree."A.txt") ? text) false];
    tree-keeps-tag-list = [
      (lib.pipe (fixtures-dir + "/vfs-test-dir/tags") [
        sundry.vfs.tree.from-src
        sundry.vfs.tree.resolve-tags
        (materialize "tagged-tree")
        (result: sundry.vfs.tree.select-by-tag (e: with e; tag {a = "1";}) result.tree)
        sundry.vfs.tree.path-strs
      ])
      [
        "=/=/=/H"
        "=/=/G"
        "=/F"
        "A"
        "C"
      ]
    ];
    tree-points-into-drv = [
      (lib.hasPrefix (toString result.drv) result.tree."A.txt".origin)
      true
    ];
    drops-empty-directory = [
      (builtins.attrNames
        (materialize "drops-empty" {
          A = {};
          B = {text = "b";};
        }).tree)
      ["B"]
    ];
    content-with-quote = [
      (builtins.readFile
        "${(materialize "content-with-quote" {"A.txt" = {text = "a'b'c";};}).drv}/A.txt")
      "a'b'c"
    ];
    name-with-shell-specials = [
      (builtins.attrNames
        (builtins.readDir
          (toString
            (materialize "shell-specials" {
              "-A.txt" = {text = "A";};
              "A$b.txt" = {text = "B";};
            })
          .drv)))
      ["-A.txt" "A$b.txt"]
    ];
    sanitized-store-name = [
      (builtins.readFile
        "${(materialize "name-with-space" {"A b.txt" = {text = "A";};}).drv}/A b.txt")
      "A"
    ];
    empty-tree = [
      (builtins.attrNames
        (builtins.readDir
          (toString (materialize "empty-tree" {}).drv)))
      []
    ];
    opaque-copy = [
      (builtins.readFile
        "${(materialize "opaque-copy" {
            "A.txt" = {origin = fixtures-dir + "/vfs-test-dir/test-files/B.txt";};
          })
          .drv}/A.txt")
      "contents of B.txt"
    ];
    authored-wins-over-origin = [
      (builtins.readFile
        "${(materialize "authored-wins" {
            "A.txt" = {
              text = "override";
              origin = fixtures-dir + "/vfs-test-dir/test-files/B.txt";
            };
          })
          .drv}/A.txt")
      "override"
    ];
    throws-on-malformed-node = [
      (sundry.does-throw
        (materialize "malformed" {
          "A.txt" = 1;
        }).drv)
      true
    ];
    lazy-text = [(sundry.does-throw-whnf (materialize "lazy" lazy-tree)) false];
    throws-on-forced-text = [
      (sundry.does-throw (materialize "lazy-forced" lazy-tree).drv)
      true
    ];
    throws-on-parent-segment = [
      (sundry.does-throw
        (materialize "parent-segment" {
          ".." = {text = "A";};
        }).drv)
      true
    ];
  };
}
