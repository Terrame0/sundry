{lib, ...}: {
  exclude = value: {exclude = value;};
  is-excluded = value: lib.isAttrs value && value ? exclude;
  unwrap-excluded = value: value.exclude;
}
