{
  lib,
  utils,
  ...
}: rec {
  assert-structure = attrs-in: template-in: let
    is-subset = subset: superset: rec {
      extra =
        lib.concatLists
        (lib.mapAttrsToList
          (name: _:
            if superset ? ${name}
            then []
            else [name])
          subset);
      success = extra == [];
    };
    recurse = attrs: template: path: let
      attrs-in-template = is-subset attrs template;
      template-in-attrs = is-subset template attrs;
    in
      if attrs-in-template.success && template-in-attrs.success
      then
        utils.attrs.merge-lists-recursive
        (lib.mapAttrsToList (name: value:
          if lib.isAttrs value
          then recurse attrs.${name} template.${name} (path ++ [name])
          else {})
        attrs)
      else {
        thing =
          map (name: "${lib.concatStringsSep "." path}.${name}")
          attrs-in-template.extra;
      };
  in rec {
    a = recurse attrs-in template-in [];
  };
  #is-subset attrs-in template-in;
  #tests = [
  #  [
  #    (assert-structure {
  #        a = 1;
  #        b = 2;
  #        c = {
  #          d = 3;
  #          e = 2;
  #        };
  #      }
  #      {
  #        a = "...";
  #        b = "...";
  #        c = {d = "...";};
  #      })
  #  ]
  #];
}
