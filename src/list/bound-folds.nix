{sundry, ...}: rec {
  max = sundry.list.best (lhs: rhs: lhs > rhs);
  min = sundry.list.best (lhs: rhs: lhs < rhs);

  tests = {
    min-single-element = [(min [1]) 1];
    max-single-element = [(max [1]) 1];
    min-ascending = [(min [1 2 3]) 1];
    max-ascending = [(max [1 2 3]) 3];
    min-negatives = [(min [(-1) (-2) (-3)]) (-3)];
    max-negatives = [(max [(-1) (-2) (-3)]) (-1)];
  };
}
