import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:green_hub_client/models/post.dart';
import 'package:green_hub_client/storages/token_storage.dart';
import 'package:green_hub_client/storages/user_credentials.dart';
import 'package:green_hub_client/utilities/user_utils.dart';
import 'package:http/http.dart' as http;
import 'package:green_hub_client/models/author.dart';
import 'package:image_picker/image_picker.dart';


class PublicationUtils {
  static Future<Map<String, dynamic>> fetchPublications(String url, BuildContext context) async {
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
        List<dynamic> content = responseData['content'];
        List<Post> posts = [];

        for (var publication in content) {
          Author author = Author(
            username: publication['author']['username'],
            userImage: publication['author']['userImage'],
            userId: publication['author']['userId'],
          );

          String? imageUrl = publication['image'] != null ? publication['image'] : null;
          String reactionType = publication['reactionType'] ?? 'null';

          Post post = Post(
            createdTime: publication['createdTime'],
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

        int totalPages = responseData['totalPages'];

        return {
          'posts': posts,
          'totalPages': totalPages,
        };
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
        return {
          'posts': [],
          'totalPages': 0,
        };
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
      return {
        'posts': [],
        'totalPages': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> fetchPublicationsWithoutToken(String url, BuildContext context) async {
    try {
      var publicationsResponse = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
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
            createdTime: publication['createdTime'],
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

        int totalPages = responseData['totalPages'];

        return {
          'posts': posts,
          'totalPages': totalPages,
        };
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
        return {
          'posts': [],
          'totalPages': 0,
        };
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
      return {
        'posts': [],
        'totalPages': 0,
      };
    }
  }

  static Future<int> setImageAndEmail(int userId, XFile image, String email) async {
    var token = await TokenStorage.getToken();

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('https://greenhubapp.ru:80/users/$userId'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['email'] = email;

    final bytes = await image.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: image.name,
    );
    request.files.add(multipartFile);

    // Отправка PATCH запроса
    var streamedResponse = await request.send();
    return streamedResponse.statusCode;
  }

  static Future<int> postData(String title, String text, List<String> tags, XFile pickedImage) async {
    try {
      var token = await TokenStorage.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://greenhubapp.ru:80/publications'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = title;
      request.fields['text'] = text;
      request.fields['tags'] = tags.join(',');

      final bytes = await pickedImage.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: pickedImage.name,
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode;
    } catch (e) {
      print('An error occurred: $e');
      return -1; // Возврат -1 в случае ошибки
    }
  }

  static Future<int> postDataWithoutPicture(String title, String text, List<String> tags) async {
    try {
      var token = await TokenStorage.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://greenhubapp.ru:80/publications'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = title;
      request.fields['text'] = text;
      request.fields['tags'] = tags.join(',');

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode;
    } catch (e) {
      print('An error occurred: $e');
      return -1; // Возврат -1 в случае ошибки
    }
  }

  static Future<int> deletePost(int postId) async {
    var token = await TokenStorage.getToken();
    final url = Uri.parse('https://greenhubapp.ru:80/publications/$postId');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode;
  }

  static Future<int> editAchievements(int userId, List<String> achievements) async {
    var token = await TokenStorage.getToken();
    final url = Uri.parse('https://greenhubapp.ru:80/users/$userId/achievements');

    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(achievements),
    );
    return response.statusCode;
  }

  static Future<void> showErrorDialog(BuildContext context, String errorMessage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<Map<String, dynamic>> getPosts(BuildContext context, Author author, int page, int postsPerPage) async {
    int userId = author.userId;
    String url = 'https://greenhubapp.ru:80/publications/user/$userId?page=$page&size=$postsPerPage';
    print(url);
    var response = await fetchPublications(url, context);

    List<Post> posts = (response['posts'] as List<dynamic>).cast<Post>();
    int totalPages = response['totalPages'] as int;

    return {
      'posts': posts,
      'totalPages': totalPages,
    };
  }

  static Future<void> deletePostUtil(State state, List<Post> posts, int index) async {
    try {
      var code = await PublicationUtils.deletePost(posts[index].id);
      if (code == 204) {
        state.setState(() {
          posts.removeAt(index);
        });
      } else {
        print('Ошибка при удалении публикации: ${code}');
      }
    } catch (e) {
      print('Произошла ошибка при удалении публикации: $e');
    }
  }

  static Future<void> checkToken() async {
    var name = UserCredentials().username;
    Author? author;
    if (name != null) {
      author = await UserUtils.fetchAuthorByUsername(name);
      if (await TokenStorage.getRole() == author?.role) {
        //успешный сценарий, токен в силе
      } else {
        //разные роли -> токен устарел -> всё обнулить и goto login
      }
    } else {
      //username = null -> token is empty -> на всякий случай всё обнулить и goto login
    }
  }
}