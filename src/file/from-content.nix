{lib, ...}: rec {
  from-content = vfs-path: contents:
    lib.setAttrByPath vfs-path {inherit contents;};
  tests = [
    [
      (from-content ["b.txt"] "contents of b.txt")
      {
        "b.txt" = {
          contents = "contents of b.txt";
        };
      }
    ]
  ];
}
