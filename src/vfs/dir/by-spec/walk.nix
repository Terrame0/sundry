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
        mlem.vfs.dir.by-spec.walk {y = "1";} (path: spec-pos: file:
          file
          // {
            contents = "${file.contents} (pos ${toString spec-pos})";
          })
        dir
      ))
      [
        "contents of a"
        "contents of b"
        "contents of c (pos 0)"
        "contents of d"
        "contents of g"
        "contents of h (pos 0)"
        "contents of f (pos 1)"
        "contents of e (pos 1)"
      ]
    ]
  ];
}
