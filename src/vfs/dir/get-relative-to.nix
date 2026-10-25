{
  lib,
  sundry,
  flake-dir,
  fixtures-dir,
  ...
}: rec {
  get-relative-to = root: path: dir: let
    root-str = lib.removeSuffix "/" (toString root);
    path-str = toString path;
    under-root =
      path-str
      == root-str
      || lib.hasPrefix "${root-str}/" path-str;
    segments = sundry.vfs.path.from-str (lib.removePrefix root-str path-str);
    vfs-path-str = sundry.vfs.path.get.str segments;

    lookup = segs:
      if lib.hasAttrByPath segs dir
      then sundry.attrs.get segs dir
      else throw "vfs.dir.get-relative-to: no vfs node at '/${vfs-path-str}'";
    cleaned = sundry.vfs.path.strip-between "{" "}" segments;
    node =
      if segments == []
      then throw "vfs.dir.get-relative-to: the path must address a node, got an empty path"
      else if lib.any (segment: segment == "") segments
      then throw "vfs.dir.get-relative-to: the path '${vfs-path-str}' has an empty segment"
      else if cleaned != segments && lib.hasAttrByPath cleaned dir
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
    then throw "vfs.dir.get-relative-to: expected a path or a string, got a '${builtins.typeOf path}'"
    else if !under-root
    then throw "vfs.dir.get-relative-to: expected a path under '${root-str}', got '${path-str}'"
    else if !(node ? origin) || origin-under-root
    then node
    else
      lib.warn
      "vfs.dir.get-relative-to: the node at '/${vfs-path-str}' has an origin outside '${root-str}'; a merged tree may need the root the node came from"
      node;
  tests = let
    root = flake-dir;
    root-file-tree = sundry.vfs.dir.from-src root;
    test-file = root + "/src/vfs/dir/get-relative-to.nix";
    tags-root = fixtures-dir + "/vfs-test-dir/tags";
    tags-raw-file-tree = sundry.vfs.dir.from-src tags-root;
    tags-resolved-file-tree = sundry.vfs.dir.resolve-tags tags-raw-file-tree;
  in {
    path-value = [(get-relative-to root test-file root-file-tree).origin test-file];
    string-path = [(toString (get-relative-to root (toString test-file) root-file-tree).origin) (toString test-file)];
    root-with-trailing-slash = [(get-relative-to (toString root + "/") test-file root-file-tree).origin test-file];
    resolved-tagged-a = [(get-relative-to tags-root (tags-root + "/A{a:1}") tags-resolved-file-tree).text "contents of A"];
    resolved-clean-a = [(get-relative-to tags-root (tags-root + "/A") tags-resolved-file-tree).text "contents of A"];
    resolved-nested-tag-f = [(get-relative-to tags-root (tags-root + "/={a:1}/F{a:2}") tags-resolved-file-tree).text "contents of F"];
    raw-tagged-a = [(get-relative-to tags-root (tags-root + "/A{a:1}") tags-raw-file-tree).text "contents of A"];
    raw-nested-tag-f = [(get-relative-to tags-root (tags-root + "/={a:1}/F{a:2}") tags-raw-file-tree).text "contents of F"];
    throws-on-trailing-slash = [(sundry.does-throw (get-relative-to root (toString test-file + "/") root-file-tree)) true];
    missing-path = [(sundry.does-throw (get-relative-to root (root + "/src/nope.nix") root-file-tree)) true];
    throws-on-empty-path = [(sundry.does-throw (get-relative-to root root root-file-tree)) true];
    rejects-vfs-relative-string = [(sundry.does-throw (get-relative-to root "/src/vfs/dir/get-relative-to.nix" root-file-tree)) true];
    rejects-segment-list = [(sundry.does-throw (get-relative-to root ["src" "vfs"] root-file-tree)) true];
    rejects-outside-root = [(sundry.does-throw (get-relative-to root /tmp/A.txt root-file-tree)) true];
  };
}
