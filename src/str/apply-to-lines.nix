{sundry, ...}: rec {
  apply-to-lines = fn: str:
    sundry.str.join-with "\n" (map fn (sundry.str.split "\n" str));

  tests = {
    multiline = [
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
    ];
    single-line = [(apply-to-lines (line: "${line}-modified") "A") "A-modified"];
  };
}
