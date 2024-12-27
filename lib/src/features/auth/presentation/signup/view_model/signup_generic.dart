class SignupGeneric {
  bool isLoading;
  bool passwordVisibility;

  SignupGeneric({
    this.isLoading = false,
    this.passwordVisibility = false,
  });

  SignupGeneric update({bool? isLoading, bool? passwordVisibility}) {
    return SignupGeneric(
      isLoading: isLoading ?? this.isLoading,
      passwordVisibility: passwordVisibility ?? this.passwordVisibility,
    );
  }
}
