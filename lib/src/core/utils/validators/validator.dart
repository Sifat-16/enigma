class Validators {
  static final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9~@#$%^&*()_+:"|}{<>?|/]{6,}$');

  static String? emailValidator(String? email) {
    if (email!.isEmpty) {
      return "Enter Email";
    } else if (!emailRegex.hasMatch(email)) {
      return "Invalid Format";
    } else {
      return null;
    }
  }

  static String? passwordValidator(String? password) {
    if (password!.isEmpty) {
      return "Enter Password";
    } else if (!passwordRegex.hasMatch(password)) {
      return "Invalid Format";
    } else {
      return null;
    }
  }
}
