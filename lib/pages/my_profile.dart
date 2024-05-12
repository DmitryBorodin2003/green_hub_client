import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import '../author.dart';
import '../post.dart';
import '../publication_utils.dart';
import '../token_storage.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'comments.dart';
import 'custom_page_route.dart';
import 'lenta.dart';
import 'login.dart';
import 'package:http/http.dart' as http;


class Profile extends StatefulWidget {
  final Author author;

  Profile({required this.author});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Post> posts = []; // Создаем список постов и инициализируем его пустым списком


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    getPosts(widget.author).then((fetchedPosts) {
      // После получения постов обновляем состояние виджета
      setState(() {
        posts = fetchedPosts;
      });
    }).catchError((error) {
      // Обрабатываем ошибку при получении постов
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ошибка'),
            content: Text(error.toString()),
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
    });
  }

  Future<List<Post>> getPosts(Author author) async {
    // Получаем ID пользователя из объекта автора
    int userId = author.userId;
    var token = await TokenStorage.getToken();
    return PublicationUtils.fetchPublications('http://46.19.66.10:8080/publications/user/$userId', token!, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCFED7),
      body: ListView(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FFF3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          ClipOval(
                            child: Image.memory(
                              base64.decode(widget.author.userImage),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),

                          SizedBox(height: 8),
                          Text(
                            widget.author.username,
                            style: TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Подписок: 12',
                            style: TextStyle(color: const Color(0xFF4c4c4c), fontFamily: 'Roboto', fontSize: 20),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Подписчиков: 100',
                            style: TextStyle(color: const Color(0xFF4c4c4c), fontFamily: 'Roboto', fontSize: 20),
                          ),
                          SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              AppMetrica.reportEvent('Click on "Edit profile" button');
                              _showEditProfileDialog();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5fc16f),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: const Color(0xFF333333)),
                                  SizedBox(width: 2),
                                  Text('Редактировать', style: TextStyle(color: const Color(0xFF333333), fontFamily: 'Roboto', fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              AppMetrica.reportEvent('Click on "Quit" button');
                              Navigator.pushReplacement(
                                context,
                                CustomPageRoute(page: Login()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5fc16f),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.exit_to_app, color: const Color(0xFF333333)),
                                  SizedBox(width: 2),
                                  Text('Выйти', style: TextStyle(color: const Color(0xFF333333), fontFamily: 'Roboto', fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Блок "Список значков" с заслугами владельца профиля
                Container(
                  margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FFF3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            'Список значков',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '🎉',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Лучший инфлюенсер',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '🥸',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Топ-10 по адекватности',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            '🐘',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Защитник животных',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],

                  ),

                ),
                SizedBox(height: 8),
                // Блок ленты с постами пользователя
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      color: Color(0xFFF5FFF3),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: Image.memory(
                                        base64.decode(post.author.userImage),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      post.author.username,
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    AppMetrica.reportEvent('Click on "Delete post" button');
                                    _showDeleteConfirmationDialog(index);
                                  },

                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFFe08684),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Удалить',
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              post.title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                            SizedBox(height: 15),
                            Text(
                              post.text,
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 15),
                            if ((post.image != null) && (post.image != ''))
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.memory(
                                    base64.decode(post.image!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${post.rating}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 16),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            AppMetrica.reportEvent('Click on "Like" button');
                                          },
                                          icon: Icon(Icons.thumb_up),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            AppMetrica.reportEvent('Click on "Dislike" button');
                                          },
                                          icon: Icon(Icons.thumb_down),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    AppMetrica.reportEvent('Click on "Comments" button');
                                    Navigator.push(
                                      context,
                                      CustomPageRoute(
                                        page: Comments(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.message),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              children: post.tags.map((tag) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(color: Colors.green),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          BottomNavigationLogic.handleNavigation(context, index);
        },
      ),
    );
  }

  void _deletePost(int index) async {
    try {
      var postId = posts[index].id;
      var token = await TokenStorage.getToken();
      // Создание URL для DELETE запроса
      print(postId);
      var deleteUrl = Uri.parse('http://46.19.66.10:8080/publications/$postId');

      // Отправка DELETE запроса
      var response = await http.delete(
        deleteUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      // Проверка статуса ответа
      if (response.statusCode == 204) {
        // Успешно удалено, обновите состояние
        setState(() {
          posts.removeAt(index);
        });
      } else {
        // Обработка ошибки удаления
        print('Ошибка при удалении публикации: ${response.statusCode}');
      }
    } catch (e) {
      // Обработка ошибки
      print('Произошла ошибка при удалении публикации: $e');
    }
  }

  // Метод для показа диалогового окна удаления поста
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Вы точно хотите удалить публикацию?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                AppMetrica.reportEvent('Click on "Cancel delete" button');
                Navigator.of(context).pop();
              },
              child: Text("Нет"),
            ),
            TextButton(
              onPressed: () {
                AppMetrica.reportEvent('Click on "Confirm delete" button');
                _deletePost(index); // Удаляем пост
                Navigator.of(context).pop(); // Закрываем диалоговое окно
              },
              child: Text("Да"),
            ),
          ],
        );
      },
    );
  }

  // Метод для показа диалогового окна редактирования своего профиля
  void _showEditProfileDialog() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFDCFED7), // Фон окна
          titlePadding: EdgeInsets.zero, // Убираем отступы заголовка
          contentPadding: EdgeInsets.symmetric(horizontal: 24.0), // Отступы контента слева и справа
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          'https://i.pinimg.com/originals/2b/64/2f/2b642f9183fa80b8c47a9d8f8971eb4d.jpg',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5), // Затемнённый фон
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 30), // Знак карандаша
                        onPressed: () {
                          // Действия при нажатии на карандаш
                          // Можно добавить выбор изображения из галереи или камеры
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0), // Отступы слева и справа
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey, // Серый цвет для надписи
                          ),
                        ),
                        SizedBox(height: 10.0), // Отступ между надписью и полем ввода
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Введите ваш Email...',
                              contentPadding: EdgeInsets.all(10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0), // Отступы слева, справа, сверху и снизу
              child: ElevatedButton(
                onPressed: () {
                  // Обработка сохранения изменений
                  // Можно добавить код сохранения данных профиля
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF5fc16f), // Зелёный цвет
                  minimumSize: Size(double.infinity, 50), // Максимальные размеры кнопки
                ),
                child: Text('Сохранить', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
      },
    );
  }

}