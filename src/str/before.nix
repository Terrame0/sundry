{lib, ...}: {
  before = sep: string:
    lib.head (lib.splitString sep string);
}
