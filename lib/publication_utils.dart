// publication_utils.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:green_hub_client/post.dart';
import 'package:green_hub_client/comment.dart';
import 'package:green_hub_client/token_storage.dart';
import 'package:http/http.dart' as http;

import 'achievement.dart';
import 'author.dart';

class PublicationUtils {
  static Future<List<Post>> fetchPublications(String url, BuildContext context) async {
    var token = await TokenStorage.getToken();
    try {
      var publicationsResponse = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (publicationsResponse.statusCode == 200) {
        var responseData = json.decode(utf8.decode(publicationsResponse.bodyBytes));
        List<dynamic> content = responseData['content']; // Получение списка публикаций
        List<Post> posts = []; // Создание списка для хранения постов

        for (var publication in content) {
          Author author = Author(
            username: publication['author']['username'],
            userImage: publication['author']['userImage'],
            userId: publication['author']['userId'],
          );

          // Добавляем проверку на null для поля image
          String? imageUrl = publication['image'] != null ? publication['image'] : null;
          String reactionType = publication['reactionType'] ?? 'null';

          Post post = Post(
            reactionType: reactionType,
            id: publication['id'],
            text: publication['text'],
            title: publication['title'],
            author: author,
            image: imageUrl ?? '',
            rating: publication['rating'],
            tags: List<String>.from(publication['tags']),
          );

          posts.add(post);
        }

        return posts;
      } else {
        // Обработка ошибки и возврат пустого списка
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ошибка'),
              content: Text('Ошибка при загрузке публикаций'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрыть всплывающее окно
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return [];
      }
    } catch (e) {
      // Обработка ошибки и возврат пустого списка
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ошибка'),
            content: Text('Ошибка при загрузке публикаций'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрыть всплывающее окно
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return [];
    }
  }

  static Future<List<List<Author>>> fetchSubscriptionsAndSubscribers(String currentUsername) async {
    var token = await TokenStorage.getToken();
    var user = await fetchAuthorByUsername(currentUsername); // Добавлено ключевое слово await
    var userId; // Объявление переменной userId

    if (user != null) {
      userId = user.userId; // Присвоение userId только если user не null
    } else {
      // Обработка случая, когда fetchAuthorByUsername вернул null
      print('Пользователь не найден');
      return [[], []]; // Возвращаем пустые списки
    }

    var subscriptionsResponse = await http.get(
      Uri.parse('http://46.19.66.10:8080/users/$userId/subscriptions'), // Используем userId
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    var subscribersResponse = await http.get(
      Uri.parse('http://46.19.66.10:8080/users/$userId/subscribers'), // Используем userId
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if ((subscriptionsResponse.statusCode == 200) && (subscribersResponse.statusCode == 200)) {
      var responseData = json.decode(utf8.decode(subscriptionsResponse.bodyBytes));
      List<dynamic> userList = responseData as List<dynamic>;
      List<Author> subscriptionList = userList.isNotEmpty
          ? userList.map<Author>((userJson) => Author.fromJson2(userJson)).toList()
          : [];

      var responseData2 = json.decode(utf8.decode(subscribersResponse.bodyBytes));
      List<dynamic> userList2 = responseData2 as List<dynamic>;
      List<Author> subscribersList = userList2.isNotEmpty
          ? userList2.map<Author>((userJson) => Author.fromJson2(userJson)).toList()
          : [];

      return [subscriptionList, subscribersList];
    } else {
      // Обработка ошибок, например, showDialog(...)
      return [[], []]; // Возвращаем пустые списки в случае ошибки
    }
  }


  static Future<int?> getUserIdByUsername(String username) async {
    try {
      var token = TokenStorage.getToken();
      var response = await http.get(
        Uri.parse('http://46.19.66.10:8080/users/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        var userId = userData['id'];

        return userId;
      } else {
        // Обработка случая, когда ответ не 200 OK
        print('Ошибка при получении данных пользователя');
        return null;
      }
    } catch (e) {
      // Обработка исключений
      print('Произошла ошибка: $e');
      return null;
    }
  }

  static Future<Author?> fetchAuthorByUsername(String username) async {
    try {
      var token = await TokenStorage.getToken();
      var response = await http.get(
        Uri.parse('http://46.19.66.10:8080/users/' + username),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var userData = json.decode(utf8.decode(response.bodyBytes));
        return Author.fromJson(userData);
      } else {
        // Обработка случая, когда ответ не 200 OK
        print(token.toString());
        print(response.statusCode);
        print('http://46.19.66.10:8080/users/' + username);
        print('Ошибка при получении данных пользователя');
        return null;
      }
    } catch (e) {
      // Обработка исключений
      print('Произошла ошибка: $e');
      return null;
    }
  }

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

  static Future<List<Achievement>> getAchievements(String url) async {
    try {
      var token = await TokenStorage.getToken();
      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
          // Добавьте другие необходимые заголовки
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

  static Future<void> sendReaction(int postId, String reactionType) async {
    String url = 'http://46.19.66.10:8080/publications/$postId/reactions';
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

      // Проверяем статус ответа
      if (response.statusCode == 201) {
        // Успешно отправлено
        print('Реакция успешно отправлена');
      } else {
        // Ошибка при отправке запроса
        print('Ошибка при отправке реакции: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Ошибка при отправке запроса: $error');
    }
  }

  static Future<void> deleteReaction(int postId) async {
    String url = 'http://46.19.66.10:8080/publications/$postId/reactions';
    var token = await TokenStorage.getToken();

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      // Проверяем статус ответа
      if (response.statusCode == 204) {
        // Успешно отправлено
        print('Реакция успешно удалена');
      } else {
        // Ошибка при отправке запроса
        print('Ошибка при отправке реакции: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Ошибка при отправке запроса: $error');
    }
  }

  static Future<List<Comment>> fetchComments(int postId) async {
    var token = await TokenStorage.getToken();
    final Uri uri = Uri.parse('http://46.19.66.10:8080/publications/$postId/comments');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body)['content'];
      return responseData.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка при загрузке комментариев');
    }
  }

  static Future<void> sendComment(int postId, String text) async {
    var token = await TokenStorage.getToken();
    final Uri uri = Uri.parse('http://46.19.66.10:8080/publications/$postId/comments');
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

}