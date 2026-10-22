{lib, ...}: merge-fn: lhs: rhs:
lib.zipAttrsWith (name: values:
    lib.foldl' (acc-value: value: merge-fn [name] acc-value value)
    (lib.head values) (lib.tail values))
[lhs rhs]
