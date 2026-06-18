{lib, ...}: rec {
  from-text = vfs-path: text:
    assert lib.isString text; lib.setAttrByPath vfs-path {inherit text;};
  tests = [
    [
      (from-text ["B.txt"] "contents of B.txt")
      {
        "B.txt" = {
          text = "contents of B.txt";
        };
      }
    ]
    [
      (from-text ["A" "B.txt"] "contents of B.txt")
      {
        A = {
          "B.txt" = {
            text = "contents of B.txt";
          };
        };
      }
    ]
  ];
}
