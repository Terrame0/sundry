args @ {lib, ...}:
lib.fix (self:
    lib.flip lib.genAttrs
    (name: import ./${name + ".nix"} (args // {bootstrap = self;}))
    [
      "merge-attrs"
      "merge-attrs-recursive"
    ])
