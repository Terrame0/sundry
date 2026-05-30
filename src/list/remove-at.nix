{lib, ...}: {
  remove-at = i: list:
    (lib.sublist 0 i list) ++ (lib.sublist (i + 1) (lib.length list) list);
}
