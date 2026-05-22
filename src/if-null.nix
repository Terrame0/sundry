{...}: {
  if-null = value: default:
    if value == null
    then default
    else value;
}
