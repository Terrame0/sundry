{
  lib,
  mlem,
  ...
}: rec {
  concat-str = paths:
    lib.foldl (
      path-acc: path: "${mlem.string.trim-right "/" path-acc}/${mlem.string.trim-left "/" path}"
    ) (lib.head paths)
    (lib.tail paths);
  tests = [
    [(concat-str ["/abc/" "/def"]) "/abc/def"]
    [(concat-str ["//abc//" "//def//" "//ghi//"]) "//abc/def/ghi//"]
  ];
}
