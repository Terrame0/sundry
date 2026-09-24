{
  sundry,
  lib,
  ...
}: rec {
  from-text = vfs-path: text:
    if vfs-path == []
    then throw "cannot create a valid vfs node with an empty path"
    else lib.setAttrByPath vfs-path {inherit text;};
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
    [(sundry.does-throw (from-text [] "contents")) true]
    [(sundry.does-throw-whnf (from-text ["A"] (throw "text was forced"))) false]
  ];
}
