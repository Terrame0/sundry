{
  sundry,
  lib,
  ...
}: rec {
  un-singleton = list:
    if lib.isList list
    then
      if lib.length list == 1
      then sundry.list.at 0 list
      else list
    else throw "\nvalue must be a list";
  tests = [
    [(un-singleton [1]) 1]
    [(un-singleton [1 2]) [1 2]]
    [(sundry.does-throw (un-singleton 1)) true]
  ];
}
