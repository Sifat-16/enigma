class LoginGeneric {
  bool isLoading;

  // bool? isContainUppercase;
  // bool? isContainLowercase;
  // bool? isContainDigit;

  LoginGeneric({
    this.isLoading = false,

    // this.isContainUppercase = true,
    // this.isContainLowercase = true,
    // this.isContainDigit = true,
  });

  LoginGeneric update({
    bool? isLoading,
    bool? passwordVisibility,
    // bool? isContainUppercase,
    // bool? isContainLowercase,
    // bool? isContainDigit,
  }) {
    return LoginGeneric(
      isLoading: isLoading ?? this.isLoading,

      // isContainUppercase: isContainUppercase ?? this.isContainUppercase,
      // isContainLowercase: isContainLowercase ?? this.isContainLowercase,
      // isContainDigit: isContainDigit ?? this.isContainDigit,
    );
  }
}
