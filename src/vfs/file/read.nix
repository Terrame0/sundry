{fixtures-dir, ...}: rec {
  read = file:
    if file ? text
    then file.text
    else builtins.readFile file.origin;

  tests = {
    authored = [(read {text = "ABC";}) "ABC"];
    authored-wins-over-origin = [
      (read {
        text = "ABC";
        origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";
      })
      "ABC"
    ];
    opaque-reads-origin = [
      (read {origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";})
      "contents of A.txt"
    ];
    string-origin = [
      (read {origin = "${toString fixtures-dir}/vfs-test-dir/test-files/B.txt";})
      "contents of B.txt"
    ];
    keeps-metadata = [
      (read {
        text = "ABC";
        tag-list = [];
      })
      "ABC"
    ];
    # -- reading a leaf must not touch unrelated lazy payloads
    does-not-force-expr = [
      (read {
        origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";
        expr = throw "expr was forced";
      })
      "contents of A.txt"
    ];
    forces-authored-text = [
      (builtins.tryEval (builtins.seq (read {text = throw "text was forced";}) true)).success
      false
    ];
  };
}
