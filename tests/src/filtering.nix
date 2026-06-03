{
  mlem,
  flake-root,
  ...
}: [
  (let
    filtered-dir =
      mlem.vfs.dir.filter
      (path: file: mlem.vfs.path.get.ext path == "txt" || file.contents == "override")
      (mlem.vfs.dir.from-real "${flake-root}/tests/vfs-test-dir/filtering");
  in [
    (mlem.vfs.dir.path-strs filtered-dir)
    [
      "filtering/a.txt"
      "filtering/b.txt"
      "filtering/nested/c.txt"
      "filtering/nested/nested/e.ini"
      "filtering/nested/nested/g.txt"
    ]
  ])
]
