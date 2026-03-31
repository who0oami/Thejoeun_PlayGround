class InputValidators {
  static final RegExp emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static final RegExp passwordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{10,16}$',
  );

  static final RegExp koreanPattern = RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣ]');

  static bool containsKorean(String value) {
    return koreanPattern.hasMatch(value);
  }

  static bool isValidEmail(String value) {
    return !containsKorean(value) && emailPattern.hasMatch(value);
  }

  static bool isValidPassword(String value) {
    return !containsKorean(value) && passwordPattern.hasMatch(value);
  }
}
