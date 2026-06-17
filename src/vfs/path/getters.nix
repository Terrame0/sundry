{
  lib,
  mlem,
  ...
}: rec {
  get = rec {
    name = path:
      lib.last path;
    name-split = path:
      lib.splitString "." (name path);
    stem = path:
      lib.concatStringsSep "."
      (mlem.list.incl-init (name-split path));
    ext = path:
      mlem.is-null
      (mlem.list.excl-last (name-split path)) "";
    str = path:
      lib.foldl (
        str-acc: dir: "${mlem.str.trim-right "/" str-acc}/${mlem.str.trim-left "/" dir}"
      ) (lib.head path)
      (lib.tail path);
  };
  tests = let
    path = ["A" "B" "C.txt"];
  in [
    [(get.name path) "C.txt"]
    [(get.stem path) "C"]
    [(get.ext path) "txt"]
    [(get.str ["A" "B"]) "A/B"]
    [(get.str ["/A/" "/B"]) "/A/B"]
    [(get.str ["//A//" "//B//" "//C//"]) "//A/B/C//"]
  ];
}
