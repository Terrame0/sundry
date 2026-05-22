{lib, ...}: {
  after = sep: string:
    lib.concatStrings (lib.tail (lib.splitString sep string));
}
