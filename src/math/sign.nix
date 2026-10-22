{...}: rec {
  sign = x:
    if x >= 0
    then 1
    else -1;
  tests = {
    positive = [(sign 2) 1];
    zero = [(sign 0) 1];
    negative = [(sign (-2)) (-1)];
  };
}
