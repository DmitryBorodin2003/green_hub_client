class UserCredentials {
  String? _username;

  // Приватный конструктор, чтобы предотвратить создание экземпляров класса извне
  UserCredentials._();

  // Статический метод для получения единственного экземпляра класса (синглтон)
  static final UserCredentials _instance = UserCredentials._();

  // Геттер для получения экземпляра класса
  factory UserCredentials() {
    return _instance;
  }

  // Метод для установки имени пользователя
  void setUsername(String username) {
    _username = username;
  }

  // Геттер для получения имени пользователя
  String? get username => _username;
}
