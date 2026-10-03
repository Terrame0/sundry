{...}: rec {
  sign = x:
    if x >= 0
    then 1
    else -1;
  tests = [
    [(sign 2) 1]
    [(sign 0) 1]
    [(sign (-2)) (-1)]
  ];
}
