import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/publication_utils.dart';
import '../achievement.dart';
import '../author.dart';
import '../post.dart';
import '../token_storage.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'comments.dart';
import 'custom_page_route.dart';
import 'package:http/http.dart' as http;
import 'iconselectiondialog.dart';
import 'lenta.dart';
import 'login.dart';


class NotMyProfile extends StatefulWidget {
  final Author author;
  bool? role = false;
  bool? moderRole = false;
  Uint8List? decodedAvatar;

  NotMyProfile({required this.author});

  @override
  State<NotMyProfile> createState() => _NotMyProfileState();
}

class _NotMyProfileState extends State<NotMyProfile> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Post> posts = [];
  List<Achievement> achievements = [];
  List<Achievement> allAchievements = [];
  bool isSubscribed = false;
  bool isBanned = false;
  bool isModerator = false;

  @override
  void initState() {
    super.initState();
    isSubscribed = widget.author.subscribed!;
    isBanned = widget.author.state! == 'VISIBLE' ? false : true;
    isModerator = widget.author.role! == 'ROLE_MODERATOR' ? true : false;
    _tabController = TabController(length: 1, vsync: this);

    getAchievements(widget.author).then((fetchedAchievements) {
      // После получения постов обновляем состояние виджета
      setState(() {
        achievements = fetchedAchievements;
        decodeImages();
      });
    }).catchError((error) {
      // Обрабатываем ошибку при получении достижений
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

    getPosts(widget.author).then((fetchedPosts) {
      // После получения постов обновляем состояние виджета
      setState(() {
        posts = fetchedPosts;
        decodeImages();
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

    checkRole();
    getAllAchievements();
  }

  // Предварительно декодировать изображения при загрузке постов
  void decodeImages() {
    widget.decodedAvatar = base64.decode(widget.author.userImage);
    for (var post in posts) {
      post.decodedImage = base64.decode(post.image);
    }
    for (var achievement in achievements) {
      achievement.decodedImage = base64Decode(achievement.image);
    }
  }

  Future<List<Post>> getPosts(Author author) async {
    int userId = author.userId;
    return PublicationUtils.fetchPublications('http://46.19.66.10:8080/publications/user/$userId', context);
  }

  Future<List<Achievement>> getAchievements(Author author) async {
    int userId = author.userId;
    return PublicationUtils.getAchievements('http://46.19.66.10:8080/users/$userId/achievements');
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
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10),
                              ClipOval(
                                child: widget.decodedAvatar != null
                                    ? Image.memory(
                                  widget.decodedAvatar!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                                    : SizedBox(), // Если decodedAvatar равен null, отображается пустой контейнер
                              ),

                              SizedBox(height: 8),
                              Text(
                                widget.author.username,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Подписок: ' + widget.author.subscriptionsCount.toString(),
                                  style: TextStyle(color: const Color(0xFF4c4c4c), fontFamily: 'Roboto', fontSize: 20),
                                ),
                              ),
                              SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Подписчиков: ' + widget.author.subscribersCount.toString(),
                                  style: TextStyle(color: const Color(0xFF4c4c4c), fontFamily: 'Roboto', fontSize: 20),
                                ),
                              ),
                              SizedBox(height: 6),
                              InkWell(
                                onTap: () {
                                  String url = isSubscribed ? 'http://46.19.66.10:8080/users/' + widget.author.userId.toString() + '/unsubscribe' : 'http://46.19.66.10:8080/users/' + widget.author.userId.toString() +'/subscribe';
                                  PublicationUtils.subscribeOrUnsubscribe(url);
                                  setState(() {
                                    isSubscribed = !isSubscribed;
                                    if (isSubscribed) {
                                      AppMetrica.reportEvent('Click on "Subscribe" button');
                                      widget.author.subscribersCount = widget.author.subscribersCount! + 1;
                                    } else {
                                      AppMetrica.reportEvent('Click on "Unsubscribe" button');
                                      widget.author.subscribersCount = widget.author.subscribersCount! - 1;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSubscribed ? const Color(0xFFe08684) : const Color(0xFF5fc16f),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                    children: [
                                      Text(
                                        isSubscribed ? 'Отписаться' : 'Подписаться',
                                        style: TextStyle(
                                          color: const Color(0xFF000000),
                                          fontFamily: 'Roboto',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ),
                              SizedBox(height: 6),
                              Visibility(
                                visible: (widget.role! || widget.moderRole!),
                                child: InkWell(
                                  onTap: () async {
                                    var code = await PublicationUtils.banOrUnbanUser(widget.author.userId, isBanned);
                                    if (code == 200) {
                                      setState(() {
                                        isBanned = !isBanned;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isBanned ? const Color(0xFFe08684) : const Color(0xFF5fc16f),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            isBanned ? 'Разблокировать' : 'Заблокировать',
                                            style: TextStyle(
                                              color: const Color(0xFF000000),
                                              fontFamily: 'Roboto',
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 6),
                              Visibility(
                                visible: widget.role!,
                                child: InkWell(
                                  onTap: () async {
                                    var code = await PublicationUtils.applyOrFireModer(widget.author.userId, isModerator);
                                    if (code == 200) {
                                      setState(() {
                                        isModerator = !isModerator;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isModerator ? const Color(0xFFe08684) : const Color(0xFF5fc16f),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min, // Минимизирует ширину Row до необходимого размера
                                        children: [
                                          Text(
                                            isModerator ? 'Разжаловать' : 'Сделать модератором',
                                            style: TextStyle(
                                              color: const Color(0xFF000000),
                                              fontFamily: 'Roboto',
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (isBanned)
                                Text(
                                  'ЗАБЛОКИРОВАН',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                            ],
                          ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Блок "Список значков" с заслугами владельца профиля
                InkWell(
                  onTap: () {
                    if (widget.role! || widget.moderRole!) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return IconSelectionDialog(
                            selectedAchievements: achievements, availableAchievements: allAchievements,
                          );
                        },
                      ).then((selectedAchievements) async {
                        // Обработка выбранных значков после закрытия диалога
                        if (selectedAchievements != null) {
                          await PublicationUtils.editAchievements(widget.author.userId, selectedAchievements);
                          Navigator.pushReplacement(
                            context,
                            CustomPageRoute(page: NotMyProfile(author: widget.author)),
                          );
                        }
                      });
                    } else {
                      print('Только администратор может открыть это окно');
                    }
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5FFF3), // Цвет фона блока
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
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: achievements.isNotEmpty ? achievements.length : 1, // Проверяем длину списка достижений
                          itemBuilder: (context, index) {
                            if (achievements.isEmpty) {
                              return Center(
                                child: Text(
                                  'У пользователя нет достижений',
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            } else {
                              return Row(
                                children: [
                                  SizedBox(
                                    width: 24, // Ширина изображения
                                    height: 24, // Высота изображения
                                    child: achievements[index].decodedImage != null
                                        ? Image.memory(
                                      achievements[index].decodedImage!,
                                      fit: BoxFit.cover, // Параметр fit для подгонки изображения
                                    )
                                        : SizedBox(),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    achievements[index].name, // Название достижения
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
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
                      color: Color(0xFFF5FFF3), // Цвет фона карточки поста
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Image.memory(
                                            widget.decodedAvatar!,
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
                                      borderRadius: BorderRadius.circular(7), // Применяем скругление углов
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7), // Применяем скругление углов
                                      child: Image.memory(
                                        post.decodedImage!,
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
                                              onPressed: () async {
                                                AppMetrica.reportEvent('Click on "Like" button');
                                                var code = await handleReaction(post, 'LIKE');
                                                if (code == 201) {
                                                  setState(() {
                                                    posts[index] = post;
                                                  });
                                                }
                                              },
                                              icon: Icon(
                                                Icons.thumb_up,
                                                color: post.reactionType == 'LIKE' ? Colors.blue : Colors.black,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                AppMetrica.reportEvent('Click on "Dislike" button');
                                                var code = await handleReaction(post, 'DISLIKE');
                                                if (code == 201) {
                                                  setState(() {
                                                    posts[index] = post;
                                                  });
                                                }
                                              },
                                              icon: Icon(
                                                Icons.thumb_down,
                                                color: post.reactionType == 'DISLIKE' ? Colors.blue : Colors.black,
                                              ),
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
                                            page: Comments(postId: post.id,),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.message),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Выводим список тегов
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
                            Visibility(
                              visible: (widget.role! || widget.moderRole!),
                              child: Positioned(
                                top: 0,
                                right: 0,
                                child: ElevatedButton(
                                  onPressed: () {
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
                              ),
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
              onPressed: () async {
                AppMetrica.reportEvent('Click on "Confirm delete" button');
                _deletePost(index);
                Navigator.of(context).pop(); // Закрываем диалоговое окно
              },
              child: Text("Да"),
            ),
          ],
        );
      },
    );
  }

  // Метод для удаления поста
  void _deletePost(int index) async {
    try {
      var code = await PublicationUtils.deletePost(posts[index].id);
      if (code == 204) {
        setState(() {
          posts.removeAt(index);
        });
      } else {
        print('Ошибка при удалении публикации: ${code}');
      }
    } catch (e) {
      print('Произошла ошибка при удалении публикации: $e');
    }
  }

  Future<void> checkRole() async {
    String? role = await TokenStorage.getRole();
    if (role == 'ROLE_ADMIN') {
      widget.role = true;
    }

    if (role == 'ROLE_MODERATOR') {
      widget.moderRole = true;
    }
    setState(() {
      widget.role;
      widget.moderRole;
    });
  }

  Future<void> getAllAchievements() async {
    allAchievements = await PublicationUtils.getAchievements('http://46.19.66.10:8080/users/achievements');
  }

  Future<int?> handleReaction(Post post, String reactionType) async {
    switch (reactionType) {
      case 'LIKE':
        if (post.reactionType == 'DISLIKE') {
          post.rating += 2;
          post.reactionType = reactionType;
        } else if (post.reactionType == 'null') {
          post.rating += 1;
          post.reactionType = reactionType;
        } else if (post.reactionType == 'LIKE') {
          post.rating -= 1;
          post.reactionType = 'null';
        }
        break;
      case 'DISLIKE':
        if (post.reactionType == 'LIKE') {
          post.rating -= 2;
          post.reactionType = reactionType;
        } else if (post.reactionType == 'null') {
          post.rating -= 1;
          post.reactionType = reactionType;
        } else if (post.reactionType == 'DISLIKE') {
          post.rating += 1;
          post.reactionType = 'null';
        }
        break;
      default:
        return -1;
    }
    int? code;
    if (post.reactionType != 'null') {
      code = await PublicationUtils.sendReaction(post.id, reactionType);
    } else {
      code = await PublicationUtils.deleteReaction(post.id);
    }
    return code;
  }
}
