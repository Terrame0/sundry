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
    name = name: path: lib.init path ++ [name];
    stem = stem: path: name (join-name stem (get.ext path)) path;
    ext = ext: path: name (join-name (get.stem path) ext) path;
  };
  tests = let
    path = ["A" "B" "C.txt"];
  in [
    [(set.name "D.md" path) ["A" "B" "D.md"]]
    [(set.stem "C'" path) ["A" "B" "C'.txt"]]
    [(set.ext "md" path) ["A" "B" "C.md"]]
    [(set.ext "" path) ["A" "B" "C"]]
    [(set.ext "css" ["A" "B"]) ["A" "B.css"]]
    [(set.stem "B'" ["A" "B"]) ["A" "B'"]]
  ];
}
