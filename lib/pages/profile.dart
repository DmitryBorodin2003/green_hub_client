import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/publication_utils.dart';
import '../achievement.dart';
import '../author.dart';
import '../post.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'comments.dart';
import 'custom_page_route.dart';
import 'iconselectiondialog.dart';


class NotMyProfile extends StatefulWidget {
  final Author author;
  bool? role = false; //роль админа
  bool? moderRole = false; //роль модератора
  Uint8List? decodedAvatar;

  NotMyProfile({required this.author});

  @override
  State<NotMyProfile> createState() => _NotMyProfileState();
}

class _NotMyProfileState extends State<NotMyProfile> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  List<Post> posts = [];
  List<Achievement> achievements = [];
  List<Achievement> allAchievements = [];
  bool isSubscribed = false;
  bool isBanned = false;
  bool isModerator = false;
  bool _isLoadingAchievements = true;
  bool _isLoadingPosts = true;
  bool _isLoadingMore = false;
  int _postPage = 0;
  final int _postsPerPage = 10;
  int _totalPages = 1;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    isSubscribed = widget.author.subscribed!;
    isBanned = widget.author.state! == 'VISIBLE' ? false : true;
    isModerator = widget.author.role! == 'ROLE_MODERATOR' ? true : false;
    _tabController = TabController(length: 1, vsync: this);
    _scrollController = ScrollController();

    getAchievements(widget.author).then((fetchedAchievements) {
      setState(() {
        achievements = fetchedAchievements;
        PublicationUtils.decodeImagesNMP(widget, posts, achievements);
        _isLoadingAchievements = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoadingAchievements = false;
      });
      PublicationUtils.showErrorDialog(context, error.toString());
    });

    _loadPosts();

    PublicationUtils.checkRoleNMP(this, widget);

    getAllAchievements();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMorePosts();
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });
    try {
      var result = await PublicationUtils.getPosts(
          context, widget.author, _postPage, _postsPerPage);
      List<Post> fetchedPosts = result['posts'];
      _totalPages = result['totalPages']; // Получаем общее количество страниц из ответа


      setState(() {
        _scrollPosition = _scrollController.position.pixels;
        posts.addAll(fetchedPosts);
        _totalPages;
        PublicationUtils.decodeImagesNMP(widget, posts, achievements);
        _isLoadingPosts = false;
        _postPage++;
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollPosition);
          }
        });
      });
    } catch (error) {
      setState(() {
        _isLoadingPosts = false;
      });
      PublicationUtils.showErrorDialog(context, error.toString());
    }


  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _postPage >= _totalPages) return; // Проверка на наличие страниц
    setState(() {
      _isLoadingMore = true;
    });

    try {
      var result = await PublicationUtils.getPosts(
          context, widget.author, _postPage, _postsPerPage);

      // Извлечение данных из результата
      List<Post> fetchedPosts = (result['posts'] as List<dynamic>).cast<Post>();

      setState(() {
        _scrollPosition = _scrollController.position.pixels;
        posts.addAll(fetchedPosts);
        PublicationUtils.decodeImagesNMP(widget, posts, achievements);
        _isLoadingMore = false;
        _postPage++;
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollPosition);
          }
        });
      });
    } catch (error) {
      setState(() {
        _isLoadingMore = false;
      });
      PublicationUtils.showErrorDialog(context, error.toString());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCFED7),
      body: ListView(
        controller: _scrollController,
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileWidget(),
                SizedBox(height: 8),
                _buildAchievementsWidget(),
                SizedBox(height: 8),
                _buildPostsWidget(),
                if (_isLoadingMore)
                  Center(child: CircularProgressIndicator()),
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

  Widget _buildAchievementsWidget() {
    return InkWell(
      onTap: () {
        // Обработчик нажатия
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
              _isLoadingAchievements // Проверка загрузки достижений
                  ? Center(child: CircularProgressIndicator()) // Индикатор загрузки
                  : ListView.builder(
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
    );
  }

  Widget _buildProfileWidget() {
    return Container(
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
                    style: TextStyle(color: const Color(0xFF4c4c4c),
                        fontFamily: 'Roboto',
                        fontSize: 20),
                  ),
                ),
                SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Подписчиков: ' + widget.author.subscribersCount.toString(),
                    style: TextStyle(color: const Color(0xFF4c4c4c),
                        fontFamily: 'Roboto',
                        fontSize: 20),
                  ),
                ),
                SizedBox(height: 6),
                InkWell(
                  onTap: () {
                    String url = isSubscribed
                        ? 'http://185.251.89.34:80/users/' +
                        widget.author.userId.toString() + '/unsubscribe'
                        : 'http://185.251.89.34:80/users/' +
                        widget.author.userId.toString() + '/subscribe';
                    PublicationUtils.subscribeOrUnsubscribe(url);
                    setState(() {
                      isSubscribed = !isSubscribed;
                      if (isSubscribed) {
                        AppMetrica.reportEvent('Click on "Subscribe" button');
                        widget.author.subscribersCount = widget.author
                            .subscribersCount! + 1;
                      } else {
                        AppMetrica.reportEvent('Click on "Unsubscribe" button');
                        widget.author.subscribersCount = widget.author
                            .subscribersCount! - 1;
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSubscribed
                          ? const Color(0xFFe08684)
                          : const Color(0xFF5fc16f),
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
                      var code = await PublicationUtils.banOrUnbanUser(
                          widget.author.userId, isBanned);
                      if (code == 200) {
                        setState(() {
                          isBanned = !isBanned;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBanned ? const Color(0xFFe08684) : const Color(
                            0xFF5fc16f),
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
                      var code = await PublicationUtils.applyOrFireModer(
                          widget.author.userId, isModerator);
                      if (code == 200) {
                        setState(() {
                          isModerator = !isModerator;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: isModerator
                            ? const Color(0xFFe08684)
                            : const Color(0xFF5fc16f),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // Минимизирует ширину Row до необходимого размера
                          children: [
                            Text(
                              isModerator
                                  ? 'Разжаловать'
                                  : 'Сделать модератором',
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
                    style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsWidget() {
    return _isLoadingPosts // Проверка загрузки постов
        ? Center(child: CircularProgressIndicator()) // Индикатор загрузки
        : ListView.builder(
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
                                  onPressed: () async {
                                    AppMetrica.reportEvent('Click on "Dislike" button');
                                    var code = await handleReaction(post, 'DISLIKE');
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
    );
  }

  Future<List<Achievement>> getAchievements(Author author) async {
    int userId = author.userId;
    return PublicationUtils.getAchievements('http://185.251.89.34:80/users/$userId/achievements');
  }

  Future<void> getAllAchievements() async {
    allAchievements = await PublicationUtils.getAchievements('http://185.251.89.34:80/users/achievements');
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
                PublicationUtils.deletePostUtil(this, posts, index);
                Navigator.of(context).pop(); // Закрываем диалоговое окно
              },
              child: Text("Да"),
            ),
          ],
        );
      },
    );
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