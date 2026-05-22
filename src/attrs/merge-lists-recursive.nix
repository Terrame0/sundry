{
  lib,
  utils,
  ...
}: rec {
  merge-lists-recursive = utils.attrs.merge-recursive-with (
    lhs: rhs:
      if lib.isList lhs && lib.isList rhs
      then lhs ++ rhs
      else rhs
  );
  tests = [
    [
      (merge-lists-recursive [
        {
          a = {
            b = {c = ["x" "y"];};
            d = ["x"];
            e = 1;
          };
        }
        {
          a = {
            b = {c = ["z"];};
            d = ["y" "z"];
            e = 2;
          };
        }
      ])
      {
        a = {
          b = {
            c = ["x" "y" "z"];
          };
          d = ["x" "y" "z"];
          e = 2;
        };
      }
    ]
  ];
}
