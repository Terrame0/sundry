{sundry, ...}: rec {
  max = sundry.list.best (lhs: rhs: lhs > rhs);
  min = sundry.list.best (lhs: rhs: lhs < rhs);
  tests = [
    [(min [1]) 1]
    [(max [1]) 1]
    [(min [1 2 3]) 1]
    [(max [1 2 3]) 3]
    [(min [(-1) (-2) (-3)]) (-3)]
    [(max [(-1) (-2) (-3)]) (-1)]
  ];
}
