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
        str-acc: dir: "${mlem.string.trim-right "/" str-acc}/${mlem.string.trim-left "/" dir}"
      ) (lib.head path)
      (lib.tail path);
  };
  tests = let
    path = ["abc" "def" "ghi.txt"];
  in [
    [(get.name path) "ghi.txt"]
    [(get.stem path) "ghi"]
    [(get.ext path) "txt"]
    [(get.str ["abc" "def"]) "abc/def"]
    [(get.str ["/abc/" "/def"]) "/abc/def"]
    [(get.str ["//abc//" "//def//" "//ghi//"]) "//abc/def/ghi//"]
  ];
}
