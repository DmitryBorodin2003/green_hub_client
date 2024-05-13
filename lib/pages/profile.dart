import 'dart:convert';
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
import 'lenta.dart';
import 'login.dart';


class NotMyProfile extends StatefulWidget {
  final Author author;
  Uint8List? decodedAvatar;

  NotMyProfile({required this.author});

  @override
  State<NotMyProfile> createState() => _NotMyProfileState();
}

class _NotMyProfileState extends State<NotMyProfile> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Post> posts = [];
  List<Achievement> achievements = [];
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    isSubscribed = widget.author.subscribed!;
    _tabController = TabController(length: 1, vsync: this);

    getAchievements(widget.author).then((fetchedAchievements) {
      // После получения постов обновляем состояние виджета
      setState(() {
        achievements = fetchedAchievements;
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
  }

  // Предварительно декодировать изображения при загрузке постов
  void decodeImages() {
    widget.decodedAvatar = base64.decode(widget.author.userImage);
    for (var post in posts) {
      post.decodedImage = base64.decode(post.image!);
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
                      Column(
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
                      SizedBox(width: 10),
                      Column(
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
                                  child: Image.memory(
                                    base64.decode(achievements[index].image), // URL изображения
                                    fit: BoxFit.cover, // Параметр fit для подгонки изображения
                                  ),
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
                                          onPressed: () {
                                            AppMetrica.reportEvent(
                                                'Click on "Like" button');
                                            handleReaction(post, 'LIKE');
                                            setState(() {
                                              posts[index] = post;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.thumb_up,
                                            color: post.reactionType == 'LIKE' ? Colors.blue : Colors.black,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            AppMetrica.reportEvent(
                                                'Click on "Dislike" button');
                                            handleReaction(post, 'DISLIKE');
                                            setState(() {
                                              posts[index] = post;
                                            });
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

  void handleReaction(Post post, String reactionType) {
    //TODO: check 201 status
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
      // Действия, если reactionType не равно 'LIKE' или 'DISLIKE'
        break;
    }
    PublicationUtils.sendReaction(post.id, reactionType);
  }
}
