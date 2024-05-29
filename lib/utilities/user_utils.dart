import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/my_profile.dart';
import 'package:green_hub_client/pages/profile.dart';
import 'package:green_hub_client/models/post.dart';
import 'package:green_hub_client/storages/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:green_hub_client/models/achievement.dart';
import 'package:green_hub_client/models/author.dart';


class UserUtils {
  static Future<int?> getUserIdByUsername(String username) async {
    try {
      var token = TokenStorage.getToken();
      var response = await http.get(
        Uri.parse('https://greenhubapp.ru:80/users/$username'),
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
        Uri.parse('https://greenhubapp.ru:80/users/' + username),
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
        print('Ошибка при получении данных пользователя');
        return null;
      }
    } catch (e) {
      // Обработка исключений
      print('Произошла ошибка: $e');
      return null;
    }
  }

  static Future<List<List<Author>>> fetchSubscriptionsAndSubscribers(String currentUsername) async {
    var token = await TokenStorage.getToken();
    var user = await fetchAuthorByUsername(currentUsername);
    var userId;

    if (user != null) {
      userId = user.userId;
    } else {
      print('Пользователь не найден');
      return [[], []];
    }

    var subscriptionsResponse = await http.get(
      Uri.parse('https://greenhubapp.ru:80/users/$userId/subscriptions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    var subscribersResponse = await http.get(
      Uri.parse('https://greenhubapp.ru:80/users/$userId/subscribers'),
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
      return [[], []]; // Возвращаем пустые списки в случае ошибки
    }
  }

  static Future<bool> checkAdminRole() async {
    String? role = await TokenStorage.getRole();
    if (role == 'ROLE_ADMIN') {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> checkRoleNMP(State state, NotMyProfile widget) async {
    String? role = await TokenStorage.getRole();
    if (role == 'ROLE_ADMIN') {
      widget.role = true;
    }

    if (role == 'ROLE_MODERATOR') {
      widget.moderRole = true;
    }
    state.setState(() {
      widget.role;
      widget.moderRole;
    });
  }

  static Future<void> checkRoleMP(State state, Profile widget) async {
    String? role = await TokenStorage.getRole();
    if (role == 'ROLE_ADMIN' || role == 'ROLE_MODERATOR') {
      widget.role = true;
    } else {
      widget.role = false;
    }
    state.setState(() {
      widget.role;
    });
  }

  static void decodeImagesNMP(NotMyProfile widget, List<Post> posts, List<Achievement> achievements) {
    widget.decodedAvatar = base64.decode(widget.author.userImage);
    for (var post in posts) {
      post.decodedImage = base64.decode(post.image);
    }
    for (var achievement in achievements) {
      achievement.decodedImage = base64Decode(achievement.image);
    }
  }

  static void decodeImagesMP(Profile widget, List<Post> posts, List<Achievement> achievements) {
    widget.decodedAvatar = base64.decode(widget.author.userImage);
    for (var post in posts) {
      post.decodedImage = base64.decode(post.image);
    }
    for (var achievement in achievements) {
      achievement.decodedImage = base64Decode(achievement.image);
    }
  }
}