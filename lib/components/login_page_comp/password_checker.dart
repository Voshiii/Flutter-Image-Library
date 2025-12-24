bool checkPasswordConstraints(String password){
  return password.length >= 8 &&
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
}