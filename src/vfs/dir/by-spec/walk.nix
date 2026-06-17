{
  lib,
  mlem,
  flake-root,
  ...
}: {
  walk = spec: fn:
    mlem.vfs.dir.walk (path: file: let
      spec-pos = mlem.vfs.file.get-spec-pos spec file;
    in
      if spec-pos == -1
      then file
      else fn path spec-pos file);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/specs" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-specs {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.collapse (path: file: file.contents) (
        mlem.vfs.dir.by-spec.walk {b = "1";} (path: spec-pos: file:
          file
          // {
            contents = "${file.contents} (pos ${toString spec-pos})";
          })
        dir
      ))
      [
        "contents of H (pos 1)"
        "contents of G (pos 1)"
        "contents of F"
        "contents of I (pos 0)"
        "contents of A"
        "contents of B"
        "contents of C (pos 0)"
        "contents of D"
        "contents of E"
      ]
    ]
  ];
}
