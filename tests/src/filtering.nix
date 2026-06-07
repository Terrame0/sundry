{
  mlem,
  flake-root,
  ...
}: [
  (let
    filtered-dir =
      mlem.vfs.dir.filter
      (path: file: mlem.vfs.path.get.ext path == "txt" || file.contents == "override")
      (mlem.vfs.dir.from-src "${flake-root}/tests/vfs-test-dir/filtering");
  in [
    (mlem.vfs.dir.path-strs filtered-dir)
    [
      "a.txt"
      "b.txt"
      "nested/c.txt"
      "nested/nested/e.ini"
      "nested/nested/g.txt"
    ]
  ])
]
