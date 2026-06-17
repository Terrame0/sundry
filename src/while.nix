{mlem, ...}: rec {
  while = cond: init-state: op: let
    recurse = prev:
      if (cond prev && !(prev ? break && prev.break))
      then recurse (prev // (op prev))
      else removeAttrs prev ["break"];
  in
    recurse init-state;

  tests = [
    [
      (while
        (state: state.x != 10)
        {x = 0;}
        (prev: {x = prev.x + 1;}))
      {x = 10;}
    ]
    [
      (while
        mlem.true-fn
        {x = 0;}
        (prev: {
          x = prev.x + 1;
          break = true;
        }))
      {x = 1;}
    ]
    [
      (while
        (state: false)
        {x = 0;}
        (prev: {x = prev.x + 1;}))
      {x = 0;}
    ]
  ];
}
