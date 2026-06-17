{lib, ...}: rec {
  from-contents = vfs-path: contents:
    assert lib.isString contents; lib.setAttrByPath vfs-path {inherit contents;};
  tests = [
    [
      (from-contents ["B.txt"] "contents of B.txt")
      {
        "B.txt" = {
          contents = "contents of B.txt";
        };
      }
    ]
    [
      (from-contents ["A" "B.txt"] "contents of B.txt")
      {
        A = {
          "B.txt" = {
            contents = "contents of B.txt";
          };
        };
      }
    ]
  ];
}
