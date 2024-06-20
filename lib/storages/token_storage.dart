import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  static Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
  }

  static Future<String?> getToken() async {
    var a = await _storage.read(key: 'token');
    if ((a != null) && (checkExp(JwtDecoder.decode(a)['exp']) == false)) {
      print('Проверку прошел');
      return a;
    }
    print('Проверку не прошел');
    return null;
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  static Future<void> clearRole() async {
    await _storage.delete(key: 'role');
  }

  static Future<void> clearUsername() async {
    await _storage.delete(key: 'username');
  }

  static bool checkExp(int exp) {
    //false - хорошо, true - пропал
    return DateTime.now().toUtc().isAfter(DateTime.fromMillisecondsSinceEpoch(exp * 1000));
  }
}
