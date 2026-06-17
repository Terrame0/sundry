{lib, ...}: rec {
  apply-to-lines = fn: str:
    lib.concatStringsSep "\n" (map fn (lib.splitString "\n" str));
  tests = [
    [
      (apply-to-lines
        (line: "${line}-modified")
        ''
          A
          B
          C'')
      ''
        A-modified
        B-modified
        C-modified''
    ]
    [(apply-to-lines (line: "${line}-modified") "A") "A-modified"]
  ];
}
