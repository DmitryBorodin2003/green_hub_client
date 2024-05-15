import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  static Future<void> clearRole() async {
    await _storage.delete(key: 'role');
  }
}
