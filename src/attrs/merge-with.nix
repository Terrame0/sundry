{lib, ...}: rec {
  merge-with = merge-fn: attrs:
    lib.zipAttrsWith (name: values:
      lib.foldl (acc-value: value: merge-fn [name] acc-value value)
      (lib.head values) (lib.tail values))
    attrs;

  tests = {
    disjoint-keys = [
      (merge-with (path: acc-value: value: value) [
        {A = 1;}
        {B = 2;}
      ])
      {
        A = 1;
        B = 2;
      }
    ];
    single-attrset = [
      (merge-with (path: acc-value: value: value) [{A = 1;}])
      {A = 1;}
    ];
    empty-input = [
      (merge-with (path: acc-value: value: value) [])
      {}
    ];
    keeps-accumulator = [
      (merge-with (path: acc-value: value: acc-value) [{A = 1;} {A = 2;}])
      {A = 1;}
    ];
    fold-subtract = [
      (merge-with (path: acc-value: value: acc-value - value) [
        {A = 10;}
        {A = 3;}
        {A = 2;}
      ])
      {A = 5;}
    ];
    returns-path = [
      (merge-with (path: acc-value: value: path) [{A = 1;} {A = 2;}])
      {A = ["A"];}
    ];
    no-collision = [
      (merge-with (path: acc-value: value: throw "collision") [
        {A = 1;}
        {B = 2;}
      ])
      {
        A = 1;
        B = 2;
      }
    ];
  };
}
