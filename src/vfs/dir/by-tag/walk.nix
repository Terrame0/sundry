{
  lib,
  mlem,
  flake-root,
  ...
}: {
  walk = tag: fn:
    mlem.vfs.dir.walk (path: file: let
      tag-pos = mlem.vfs.file.get-tag-pos tag file;
    in
      if tag-pos == -1
      then file
      else fn path tag-pos file);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.collapse (path: file: file.text) (
        mlem.vfs.dir.by-tag.walk {b = "1";} (path: tag-pos: file:
          file
          // {
            text = "${file.text} (pos ${toString tag-pos})";
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
