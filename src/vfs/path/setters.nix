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
    name = name: path:
      if path == []
      then throw "\nan empty path has no name"
      else lib.init path ++ [name];
    stem = stem: path: name (join-name stem (get.ext path)) path;
    ext = ext: path: name (join-name (get.stem path) ext) path;
  };
  tests = {
    set-name = [(set.name "D.md" ["A" "B" "C.txt"]) ["A" "B" "D.md"]];
    set-stem = [(set.stem "C'" ["A" "B" "C.txt"]) ["A" "B" "C'.txt"]];
    set-ext = [(set.ext "md" ["A" "B" "C.txt"]) ["A" "B" "C.md"]];
    set-empty-ext = [(set.ext "" ["A" "B" "C.txt"]) ["A" "B" "C"]];
    set-name-no-ext = [(set.name "B.md" ["A" "B"]) ["A" "B.md"]];
    set-stem-no-ext = [(set.stem "B'" ["A" "B"]) ["A" "B'"]];
    set-ext-no-ext = [(set.ext "md" ["A" "B"]) ["A" "B.md"]];
    set-name-throws-on-empty = [(sundry.does-throw (set.name "A.md" [])) true];
    set-stem-throws-on-empty = [(sundry.does-throw (set.stem "A" [])) true];
    set-ext-throws-on-empty = [(sundry.does-throw (set.ext "md" [])) true];
  };
}
