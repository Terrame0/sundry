{
  sundry,
  fixtures-dir,
  ...
}: rec {
  edit = fn: file: file // {text = fn (sundry.vfs.file.read file);};

  tests = {
    transforms-text = [(edit (text: text + "!") {text = "ABC";}).text "ABC!"];
    keeps-origin = [
      (edit (text: text) {
        text = "ABC";
        origin = "/A.txt";
      }).origin
      "/A.txt"
    ];
    keeps-metadata = [
      (edit (text: text) {
        text = "ABC";
        tag-list = [{a = "1";}];
      }).tag-list
      [{a = "1";}]
    ];
    authored-wins-over-origin = [
      (edit (text: text) {
        text = "ABC";
        origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";
      }).text
      "ABC"
    ];
    authors-opaque-leaf = [
      (edit (text: text + "!") {origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";}).text
      "contents of A.txt!"
    ];
    opaque-origin-survives = [
      (edit (text: text + "!") {origin = fixtures-dir + "/vfs-test-dir/test-files/A.txt";}).origin
      (fixtures-dir + "/vfs-test-dir/test-files/A.txt")
    ];
    round-trip = [
      (sundry.vfs.file.read (edit (text: text + "!") {text = "ABC";}))
      "ABC!"
    ];
  };
}
