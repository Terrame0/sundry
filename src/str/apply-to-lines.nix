{lib, ...}: rec {
  apply-to-lines = fn: str:
    lib.concatStringsSep "\n" (map fn (lib.splitString "\n" str));
  tests = [
    [
      (apply-to-lines
        (line: "${line}-modified")
        ''
          a
          b
          c'')
      ''
        a-modified
        b-modified
        c-modified''
    ]
  ];
}
