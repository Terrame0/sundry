{
  lib,
  sundry,
  ...
}: let
  get = sundry.vfs.path.get;
  join-name = stem: ext:
    if ext == ""
    then stem
    else "${stem}.${ext}";
in rec {
  set = rec {
    basename = basename: path:
      if path == []
      then throw "an empty path has no name"
      else lib.init path ++ [basename];
    stem = stem: path: basename (join-name stem (get.ext path)) path;
    ext = ext: path: basename (join-name (get.stem path) ext) path;
  };

  tests = {
    basename = [(set.basename "D.md" ["A" "B" "C.txt"]) ["A" "B" "D.md"]];
    stem = [(set.stem "C'" ["A" "B" "C.txt"]) ["A" "B" "C'.txt"]];
    ext = [(set.ext "md" ["A" "B" "C.txt"]) ["A" "B" "C.md"]];
    empty-ext = [(set.ext "" ["A" "B" "C.txt"]) ["A" "B" "C"]];
    basename-no-ext = [(set.basename "B.md" ["A" "B"]) ["A" "B.md"]];
    stem-no-ext = [(set.stem "B'" ["A" "B"]) ["A" "B'"]];
    ext-no-ext = [(set.ext "md" ["A" "B"]) ["A" "B.md"]];
    basename-throws-on-empty = [(sundry.does-throw (set.basename "A.md" [])) true];
    stem-throws-on-empty = [(sundry.does-throw (set.stem "A" [])) true];
    ext-throws-on-empty = [(sundry.does-throw (set.ext "md" [])) true];
  };
}
