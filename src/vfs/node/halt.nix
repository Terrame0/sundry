{
  sundry,
  lib,
  ...
}: rec {
  halt = path: node:
    lib.all (sundry.apply [path node])
    (with sundry.vfs.node; [validate is-leaf]);

  tests = {
    halt-leaf = [(halt ["..."] {text = "...";}) true];
    halt-directory = [(halt ["..."] {a = {};}) false];
    halt-lazy-expr = [
      (halt ["..."] {
        origin = "...";
        expr = throw "expr was forced";
      })
      true
    ];
    throws-on-invalid-node = [(sundry.does-throw (halt ["x"] {a = 10;})) true];
    throws-on-non-attrs = [(sundry.does-throw (halt ["x"] 10)) true];
  };
}
