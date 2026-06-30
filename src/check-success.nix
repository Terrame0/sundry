{...}: {
  check-success = value: attrs:
    if !attrs ? success
    then throw "success validation attrset must have the 'success' attribute"
    else if !attrs ? error-msg
    then throw "success validation attrset must have the 'error-msg' attribute"
    else if attrs.success
    then value
    else throw "\n${attrs.error-msg}";
}
