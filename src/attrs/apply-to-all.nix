{lib, ...}: rec {
  apply-to-all = fn: init-attrs: let
    recurse = attrs:
      lib.mapAttrs (name: value:
        if lib.isAttrs value
        then recurse (fn name value)
        else value)
      attrs;
  in
    recurse init-attrs;
  tests = [
    #[
    #  (apply-to-all (name: value:
    #    value
    #    // {
    #      inherit name;
    #    }) {
    #    a = {
    #      b = 10;
    #      c = {};
    #    };
    #  })
    #]
  ];
}
