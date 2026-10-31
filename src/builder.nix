{
  sundry,
  lib,
  pkgs,
  fixtures-dir,
  ...
}: rec {
  builder = {
    name,
    script,
    packages ? [],
    src ? null,
    env ? {},
  }: let
    wrapper =
      # -< nu >-
      ''
        let attrs = open $env.NIX_ATTRS_JSON_FILE
        $attrs.env | load-env
        if ($attrs.src? != null) { $env.src = $attrs.src }
        $attrs.outputs | load-env
        $env.PATH = $attrs.packages
      '';
  in
    derivation {
      name = lib.strings.sanitizeDerivationName name;
      packages =
        map (path: "${path}/bin")
        (packages ++ (with pkgs; [nushell coreutils]));
      inherit env src;
      inherit (pkgs.stdenvNoCC.hostPlatform) system;
      __structuredAttrs = true;
      allowSubstitutes = false;
      builder = lib.getExe pkgs.nushell;
      args = [
        "-n"
        (pkgs.writeText "builder.nu"
          (sundry.str.join-with "\n" [wrapper script]))
      ];
    };

  tests = let
    read-env = drv:
      lib.pipe drv [
        builtins.readFile
        builtins.unsafeDiscardStringContext
        builtins.fromJSON # -- fromJSON errors out on strings with context
      ];
  in {
    roundtrip = let
      src = fixtures-dir + "/vfs-test-dir/test-files";
      env = {
        A = "abc";
        B = {
          C = 10;
          D = "abc";
        };
      };
      test-drv = builder {
        name = "test-drv";
        inherit src env;
        script =
          # -< nu >-
          ''
            $env | to json --serialize | save -f $env.out
          '';
      };
      env-readback = read-env test-drv;
      compared = sundry.attrs.compare env-readback env;
    in [
      {
        inherit (compared) missing;
        matched =
          sundry.attrs.walk
          (path: pair: sundry.list.at 0 pair == sundry.list.at 1 pair)
          compared.matched;
        inherit (env-readback) src out;
      }
      {
        missing = {};
        matched = {
          A = true;
          B = {
            C = true;
            D = true;
          };
        };
        src = sundry.path.to-store-str src;
        out = sundry.path.to-store-str test-drv;
      }
    ];

    packages-in-path = [
      (builtins.readFile
        (builder {
          name = "packages-in-path";
          packages = [
            (pkgs.runCommandLocal "fake-tool" {}
              # -< bash >-
              ''
                mkdir -p $out/bin
                printf '#!/bin/sh\nprintf fake-tool-ran\n' > $out/bin/fake-tool
                chmod +x $out/bin/fake-tool
              '')
          ];
          script =
            # -< nu >-
            ''
              ^fake-tool | save -f $env.out
            '';
        }))
      "fake-tool-ran"
    ];

    default-coreutils-in-path = [
      (builtins.readFile
        (builder {
          name = "default-coreutils-in-path";
          script =
            # -< nu >-
            ''
              ^cp ${builtins.toFile "builder-cp-source.txt" "abc"} $env.out
            '';
        }))
      "abc"
    ];

    env-does-not-clobber = let
      out = builder {
        name = "env-does-not-clobber";
        env = {
          out = "/clobber";
          PATH = "/nowhere";
          A = "kept";
        };
        script =
          # -< nu >-
          ''
            { out: $env.out, path: $env.PATH, a: $env.A }
            | to json --serialize
            | save -f $env.out
          '';
      };
    in [
      (read-env out)
      {
        out = toString out;
        path = map (path: "${path}/bin") [pkgs.nushell pkgs.coreutils];
        a = "kept";
      }
    ];

    src-null = [
      (read-env (builder {
        name = "src-null";
        script =
          # -< nu >-
          ''
            { present: ($env.src? != null) } | to json | save -f $env.out
          '';
      }))
      .present
      false
    ];

    attrs-available = let
      out = builder {
        name = "attrs-available";
        script =
          # -< nu >-
          ''
            { out: $attrs.outputs.out, has-env: ("env" in $attrs) }
            | to json --serialize
            | save -f $env.out
          '';
      };
    in [
      (read-env out)
      {
        out = toString out;
        has-env = true;
      }
    ];

    env-types = let
      marker = builtins.toFile "builder-env-marker.txt" "m";
    in [
      (read-env (builder {
        name = "env-types";
        env = {
          yes = true;
          no = false;
          list = [1 2 3];
          nothing = null;
          store = marker;
        };
        script =
          # -< nu >-
          ''
            {
              yes: $env.yes
              no: $env.no
              list: $env.list
              nothing: $env.nothing
              store: $env.store
            }
            | to json --serialize
            | save -f $env.out
          '';
      }))
      {
        yes = true;
        no = false;
        list = [1 2 3];
        nothing = null;
        store = marker;
      }
    ];

    name-sanitized = [
      (lib.hasSuffix "-a-b" (toString (builder {
        name = "a b";
        script =
          # -< nu >-
          ''
            "x" | save -f $env.out
          '';
      })))
      true
    ];
  };
}
