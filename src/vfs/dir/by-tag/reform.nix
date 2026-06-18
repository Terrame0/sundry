{
  lib,
  mlem,
  flake-root,
  ...
}: {
  reform = tag: fn:
    mlem.vfs.dir.reform (path: file: let
      tag-pos = mlem.vfs.file.get-tag-pos tag file;
    in
      if tag-pos == -1
      then {
        omit = true;
        path = [];
        value = {};
      }
      else fn path tag-pos file);

  tests = let
    dir = lib.pipe "${flake-root}/tests/vfs-test-dir/tags" [
      mlem.vfs.dir.from-src
      (mlem.vfs.dir.resolve-tags {strip = true;})
    ];
  in [
    [
      (mlem.vfs.dir.by-tag.reform {b = "1";} (path: tag-pos: file: {
          path = [(lib.last path)];
          value = tag-pos;
        })
        dir)
      {
        C = 0;
        H = 1;
        G = 1;
        I = 0;
      }
    ]
  ];
}
