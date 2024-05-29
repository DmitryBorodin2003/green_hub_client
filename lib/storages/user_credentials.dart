class UserCredentials {
  String? _username;

  UserCredentials._();

  static final UserCredentials _instance = UserCredentials._();

  factory UserCredentials() {
    return _instance;
  }

  void setUsername(String username) {
    _username = username;
  }

  String? get username => _username;
}
