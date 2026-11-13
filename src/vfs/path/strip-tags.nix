{
  sundry,
  config,
  ...
}: rec {
  strip-tags = with config.vfs.tags; sundry.vfs.path.strip-between lsep rsep;

  tests = {
    strips-annotations = [(strip-tags ["A{a:1}" "B{b:2,3}" "C"]) ["A" "B" "C"]];
    keeps-unmarked = [(strip-tags ["A" "B"]) ["A" "B"]];
    empty-path = [(strip-tags []) []];
    multiple-blocks = [(strip-tags ["A{a:1}{b:2}"]) ["A"]];
    directory-segment = [(strip-tags ["={a:1}" "F{a:2}"]) ["=" "F"]];
    idempotent = [
      (strip-tags (strip-tags ["A{a:1}" "B"]))
      (strip-tags ["A{a:1}" "B"])
    ];
  };
}
