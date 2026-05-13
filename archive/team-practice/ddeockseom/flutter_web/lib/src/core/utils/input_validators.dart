class InputValidators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static bool isValidEmail(String value) {
    return _emailRegExp.hasMatch(value.trim());
  }

  static bool isValidPassword(String value) {
    return value.trim().length >= 8;
  }
}
