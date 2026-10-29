{sundry, ...}: let
  match-base = merge: tag-list: tag-spec:
    sundry.vfs.tag.faceted-match (merge tag-list) tag-spec;
in rec {
  tag = match-base sundry.attrs.merge.concat;
  deepest-tag = match-base sundry.attrs.merge.override;
  tests = let
    tag-list = [{a = "1";} {b = ["1" "2"];}];
    override-list = [{modules = "user";} {a = "1";} {modules = "system";}];
  in {
    exact-match = [(tag tag-list {a = "1";}) true];
    list-contains = [(tag tag-list {b = "2";}) true];
    conjunction = [(tag tag-list ({a = "1";} // {b = "2";})) true];
    empty-spec = [(tag [] {}) true];
    empty-spec-miss = [(tag [] {a = "1";}) false];

    deepest-overrides = [(deepest-tag override-list {modules = "system";}) true];
    deepest-shadowed = [(deepest-tag override-list {modules = "user";}) false];
    deepest-empty-spec = [(deepest-tag override-list {modules = [];}) true];
    deepest-absent = [(deepest-tag override-list {absent = "x";}) false];
    deepest-single = [(deepest-tag [{modules = "user";} {a = "1";}] {modules = "user";}) true];
    deepest-list-value = [(deepest-tag [{modules = ["system" "user"];}] {modules = "user";}) true];
    deepest-empty-tag = [(deepest-tag [] {}) true];
    deepest-empty-tag-miss = [(deepest-tag [] {modules = "system";}) false];
  };
}
