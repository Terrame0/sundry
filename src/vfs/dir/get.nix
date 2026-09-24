{
  lib,
  sundry,
  flake-root,
  ...
}: rec {
  get = path: dir: let
    segments =
      if lib.isPath path
      then
        lib.pipe path [
          toString
          sundry.path.strip-store
          sundry.vfs.path.from-str
        ]
      else if lib.isString path
      then sundry.vfs.path.from-str path
      else if lib.isList path && lib.all lib.isString path
      then path
      else throw "the path should either be of type 'path', of type 'string', or be a vfs path";

    path-str = sundry.vfs.path.get.str segments;

    lookup = segs:
      lib.foldl (
        acc: key:
          if lib.isAttrs acc && acc ? ${key}
          then acc.${key}
          else throw "vfs.dir.get: no vfs node at '/${path-str}'"
      )
      dir
      segs;
    cleaned = sundry.vfs.path.strip-between "{" "}" segments;
    node =
      if segments == []
      then throw "vfs.dir.get: the path must address a node, got an empty path"
      else if lib.any (segment: segment == "") segments
      then throw "vfs.dir.get: the path '${path-str}' has an empty segment"
      else if cleaned != segments && lib.hasAttrByPath cleaned dir
      then lookup cleaned
      else lookup segments;

    origin-root =
      if node ? origin && (lib.isPath node.origin || lib.isString node.origin)
      then sundry.path.store-root (toString node.origin)
      else null;
  in
    if !(lib.isPath path) || origin-root == null
    then node
    else if origin-root != sundry.path.store-root (toString path)
    then
      lib.warn
      "vfs.dir.get: store object mismatch for '/${path-str}': the path is under '${sundry.path.store-root (toString path)}' but the node origin is under '${origin-root}'"
      node
    else node;
  tests = let
    dir = sundry.vfs.dir.from-src flake-root;
    test-file = ["src" "vfs" "dir" "get.nix"];
    expected = "/src/vfs/dir/get.nix";
    tags-raw = sundry.vfs.dir.from-src (flake-root + "/tests/vfs-test-dir/tags");
    tags-resolved = sundry.vfs.dir.resolve-tags tags-raw;
  in [
    [(sundry.path.strip-store (get ./get.nix dir).origin) expected]
    [(sundry.path.strip-store (get "/src/vfs/dir/get.nix" dir).origin) expected]
    [(sundry.path.strip-store (get test-file dir).origin) expected]
    [(get "/A{a:1}" tags-resolved).text "contents of A"]
    [(get "/A" tags-resolved).text "contents of A"]
    [(get "/={a:1}/F{a:2}" tags-resolved).text "contents of F"]
    [(get "/A{a:1}" tags-raw).text "contents of A"]
    [(get "/={a:1}/F{a:2}" tags-raw).text "contents of F"]
    [(sundry.does-throw (get "/src/vfs/dir/get.nix/" dir)) true]
    [(sundry.does-throw (get "/src/nope.nix" dir)) true]
    [(sundry.does-throw (get "/" dir)) true]
    [(sundry.does-throw (get ["src" 10] dir)) true]
  ];
}
