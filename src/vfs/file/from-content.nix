{lib, ...}: rec {
  from-contents = vfs-path: contents:
    assert lib.isString contents; lib.setAttrByPath vfs-path {inherit contents;};
  tests = [
    [
      (from-contents ["b.txt"] "contents of b.txt")
      {
        "b.txt" = {
          contents = "contents of b.txt";
        };
      }
    ]
  ];
}
