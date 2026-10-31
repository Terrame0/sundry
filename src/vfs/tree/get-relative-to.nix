{
  lib,
  sundry,
  flake-dir,
  fixtures-dir,
  ...
}: rec {
  get-relative-to = root: path: tree: let
    root-str = lib.removeSuffix "/" (toString root);
    path-str = toString path;
    under-root =
      path-str
      == root-str
      || lib.hasPrefix "${root-str}/" path-str;
    segments = sundry.vfs.path.from-str (lib.removePrefix root-str path-str);

    lookup = segs:
      if lib.hasAttrByPath segs tree
      then sundry.attrs.get segs tree
      else throw "vfs.tree.get-relative-to: no vfs node at ${sundry.str.pretty segments}";
    cleaned = sundry.vfs.path.strip-between "{" "}" segments;
    node =
      if segments == []
      then throw "vfs.tree.get-relative-to: the path must address a node, got an empty path"
      else if cleaned != segments && lib.hasAttrByPath cleaned tree
      then lookup cleaned
      else lookup segments;

    origin-under-root =
      node ? origin
      && lib.any (sundry.apply [node.origin]) [lib.isPath lib.isString]
      && (let
        origin-str = toString node.origin;
      in
        origin-str == root-str || lib.hasPrefix "${root-str}/" origin-str);
  in
    if !(lib.any (sundry.apply [path]) [lib.isPath lib.isString])
    then throw "vfs.tree.get-relative-to: expected a path or a string, got a '${builtins.typeOf path}'"
    else if !under-root
    then throw "vfs.tree.get-relative-to: expected a path under '${root-str}', got '${path-str}'"
    else if !(node ? origin) || origin-under-root
    then node
    else
      lib.warn
      "vfs.tree.get-relative-to: the node at ${sundry.str.pretty segments} has an origin outside '${root-str}'; a merged tree may need the root the node came from"
      node;

  tests = let
    root = flake-dir + "/src";
    root-tree = sundry.vfs.tree.from-src root;
    test-file = root + "/vfs/tree/get-relative-to.nix";
    tags-root = fixtures-dir + "/vfs-test-dir/tags";
    tags-raw-tree = sundry.vfs.tree.from-src tags-root;
    tags-resolved-tree = sundry.vfs.tree.resolve-tags tags-raw-tree;
  in {
    path-value = [(get-relative-to root test-file root-tree).origin test-file];
    string-path = [(toString (get-relative-to root (toString test-file) root-tree).origin) (toString test-file)];
    root-with-trailing-slash = [(get-relative-to (toString root + "/") test-file root-tree).origin test-file];
    resolved-tagged-a = [(sundry.vfs.file.read (get-relative-to tags-root (tags-root + "/A{a:1}") tags-resolved-tree)) "contents of A"];
    resolved-clean-a = [(sundry.vfs.file.read (get-relative-to tags-root (tags-root + "/A") tags-resolved-tree)) "contents of A"];
    resolved-nested-tag-f = [(sundry.vfs.file.read (get-relative-to tags-root (tags-root + "/={a:1}/F{a:2}") tags-resolved-tree)) "contents of F"];
    raw-tagged-a = [(sundry.vfs.file.read (get-relative-to tags-root (tags-root + "/A{a:1}") tags-raw-tree)) "contents of A"];
    raw-nested-tag-f = [(sundry.vfs.file.read (get-relative-to tags-root (tags-root + "/={a:1}/F{a:2}") tags-raw-tree)) "contents of F"];
    throws-on-trailing-slash = [(sundry.does-throw (get-relative-to root (toString test-file + "/") root-tree)) true];
    missing-path = [(sundry.does-throw (get-relative-to root (root + "/nope.nix") root-tree)) true];
    throws-on-empty-path = [(sundry.does-throw (get-relative-to root root root-tree)) true];
    rejects-vfs-relative-string = [(sundry.does-throw (get-relative-to root "/vfs/tree/get-relative-to.nix" root-tree)) true];
    rejects-segment-list = [(sundry.does-throw (get-relative-to root ["vfs"] root-tree)) true];
    rejects-outside-root = [(sundry.does-throw (get-relative-to root /tmp/A.txt root-tree)) true];
  };
}
