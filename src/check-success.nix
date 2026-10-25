{sundry, ...}: rec {
  check-success = value: attrs:
    if !attrs ? success
    then throw "success validation attrset must have the 'success' attribute"
    else if !attrs ? error-msg
    then throw "success validation attrset must have the 'error-msg' attribute"
    else if attrs.success
    then value
    else throw "${attrs.error-msg}";

  tests = {
    success-returns-value = [
      (check-success "A" {
        success = true;
        error-msg = "B";
      })
      "A"
    ];
    failure-throws = [
      (sundry.does-throw (check-success "A" {
        success = false;
        error-msg = "B";
      }))
      true
    ];
    missing-success = [(sundry.does-throw (check-success "A" {error-msg = "B";})) true];
    missing-error-msg = [(sundry.does-throw (check-success "A" {success = true;})) true];
  };
}
