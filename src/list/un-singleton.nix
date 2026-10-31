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
    else throw "value must be a list";

  tests = {
    single-element = [(un-singleton [1]) 1];
    multiple-elements = [(un-singleton [1 2]) [1 2]];
    non-list-throws = [(sundry.does-throw (un-singleton 1)) true];
  };
}
