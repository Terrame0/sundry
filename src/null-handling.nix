{...}: {
  is-null = value: default:
    if value == null
    then default
    else value;
  not-null = value: default:
    if value != null
    then default
    else value;
}
