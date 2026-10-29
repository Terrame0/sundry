{
  lib,
  sundry,
  ...
}: rec {
  get = rec {
    basename = path:
      if path == []
      then throw "an empty path has no name"
      else lib.last path;
    basename-split = path:
      sundry.str.split "." (basename path);
    stem = path:
      sundry.str.join-with "."
      (sundry.list.incl-init (basename-split path));
    ext = path:
      sundry.is-null
      (sundry.list.excl-last (basename-split path)) "";
    str = path:
      if path != []
      then
        lib.foldl (
          str-acc: dir: "${sundry.str.trim-right "/" str-acc}/${sundry.str.trim-left "/" dir}"
        ) (lib.head path)
        (lib.tail path)
      else "";
  };
  tests = {
    basename = [(get.basename ["A" "B" "C.txt"]) "C.txt"];
    stem = [(get.stem ["A" "B" "C.txt"]) "C"];
    ext = [(get.ext ["A" "B" "C.txt"]) "txt"];
    str-join = [(get.str ["A" "B"]) "A/B"];
    str-trim-left = [(get.str ["/A/" "/B"]) "/A/B"];
    str-collapse-slashes = [(get.str ["//A//" "//B//" "//C//"]) "//A/B/C//"];
    str-empty = [(get.str []) ""];
    basename-throws-on-empty = [(sundry.does-throw (get.basename [])) true];
    stem-throws-on-empty = [(sundry.does-throw (get.stem [])) true];
    ext-throws-on-empty = [(sundry.does-throw (get.ext [])) true];
  };
}
