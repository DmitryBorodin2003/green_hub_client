import 'dart:convert';
import '../models/achievement.dart';
import '../models/comment.dart';
import '../storages/token_storage.dart';
import 'package:http/http.dart' as http;

class ActionUtils {
  static Future<void> subscribeOrUnsubscribe(String url) async {
    try {
      var token = await TokenStorage.getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
          // Добавьте другие необходимые заголовки
        },
      );

      if (response.statusCode == 200) {
        // Обработка успешного ответа
        print('Запрос выполнен успешно');
      } else {
        // Обработка случая, когда ответ не 200 OK
        print(response.statusCode);
        print('Ошибка при выполнении запроса');
      }
    } catch (e) {
      // Обработка исключений
      print('Произошла ошибка: $e');
    }
  }

  static Future<int> applyOrFireModer(int userId, bool status) async {
    String url = status ? 'https://greenhubapp.ru:80/users/$userId/downgrade' : 'https://greenhubapp.ru:80/users/$userId/upgrade';

    try {
      var token = await TokenStorage.getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode;
    } catch (e) {
      // Обработка исключений
      print('Произошла ошибка: $e');
      return -1; // Возвращаем -1 в случае ошибки
    }
  }

  static Future<int> banOrUnbanUser(int userId, bool status) async {
    String url = status ? 'https://greenhubapp.ru:80/users/$userId/unban' : 'https://greenhubapp.ru:80/users/$userId/ban';
    try {
      var token = await TokenStorage.getToken();
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode;
    } catch (e) {
      // Обработка исключений
      print('Произошла ошибка: $e');
      return -1; // Возвращаем -1 в случае ошибки
    }
  }

  static Future<List<Achievement>> getAchievements(String url) async {
    try {
      var token = await TokenStorage.getToken();
      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Обработка успешного ответа
        List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        List<Achievement> achievements = jsonList.map((json) => Achievement.fromJson(json)).toList();
        return achievements;
      } else {
        // Обработка случая, когда ответ не 200 OK
        print(response.statusCode);
        print('Ошибка при выполнении запроса');
        return []; // Возвращаем пустой список в случае ошибки
      }
    } catch (e) {
      // Обработка исключений
      print('Произошла ошибка: $e');
      return []; // Возвращаем пустой список в случае ошибки
    }
  }

  static Future<int?> sendReaction(int postId, String reactionType) async {
    String url = 'https://greenhubapp.ru:80/publications/$postId/reactions';
    var token = await TokenStorage.getToken();

    String requestBodyJson = json.encode({
      'reactionType': reactionType,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: requestBodyJson,
      );
      return response.statusCode;
    } catch (error) {
      print('Ошибка при отправке запроса: $error');
    }
  }

  static Future<int?> deleteReaction(int postId) async {
    String url = 'https://greenhubapp.ru:80/publications/$postId/reactions';
    var token = await TokenStorage.getToken();

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode;
    } catch (error) {
      print('Ошибка при отправке запроса: $error');
    }
  }

  static Future<List<Comment>> fetchComments(int postId) async {
    var token = await TokenStorage.getToken();
    final Uri uri = Uri.parse('https://greenhubapp.ru:80/publications/$postId/comments');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes))['content'];
      return responseData.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка при загрузке комментариев');
    }
  }

  static Future<void> sendComment(int postId, String text) async {
    var token = await TokenStorage.getToken();
    final Uri uri = Uri.parse('https://greenhubapp.ru:80/publications/$postId/comments');
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> body = {
      'text': text,
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      // Если успешно отправлено, ничего не возвращаем
      return;
    } else {
      throw Exception('Ошибка при отправке комментария');
    }
  }

  static Future<void> setEmail(int userId, String email) async {
    var token = await TokenStorage.getToken();

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('https://greenhubapp.ru:80/users/$userId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['email'] = email;

    // Отправка PATCH запроса
    var streamedResponse = await request.send();
    print(streamedResponse.statusCode);
  }
}