{utils, ...}: rec {
  recurse =
    utils.attrs.merge-with-resolvers
    (with utils.attrs.merge-resolvers; [
      recurse
      override
    ]);
  tests = [
    [
      (recurse [
        {
          a = 1;
          b = {c = 1;};
        }
        {
          a = 2;
          b = {c = 2;};
        }
      ])
      {
        a = 2;
        b = {
          c = 2;
        };
      }
    ]
  ];
}
