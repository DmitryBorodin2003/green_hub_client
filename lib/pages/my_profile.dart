import 'dart:convert';
import 'dart:typed_data';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/models/achievement.dart';
import 'package:green_hub_client/models/author.dart';
import 'package:green_hub_client/models/post.dart';
import 'package:green_hub_client/utilities/publication_utils.dart';
import '../storages/token_storage.dart';
import 'package:green_hub_client/bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:green_hub_client/bottom_navigation_bar/bottom_navigation_logic.dart';
import '../utilities/action_utils.dart';
import '../utilities/user_utils.dart';
import 'comments.dart';
import 'package:green_hub_client/utilities/custom_page_route.dart';
import 'package:green_hub_client/utilities/iconselectiondialog.dart';
import 'login.dart';
import 'package:image_picker/image_picker.dart';


class Profile extends StatefulWidget {
  Author author;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  Uint8List? decodedAvatar;
  bool? role = false;

  Profile({required this.author});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  List<Post> posts = [];
  List<Achievement> achievements = [];
  List<Achievement> allAchievements = [];

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
    _tabController = TabController(length: 1, vsync: this);
    _scrollController = ScrollController();

    getAchievements(widget.author).then((fetchedAchievements) {
      setState(() {
        achievements = fetchedAchievements;
        UserUtils.decodeImagesMP(widget, posts, achievements);
        _isLoadingAchievements = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoadingAchievements = false;
      });
      PublicationUtils.showErrorDialog(context, error.toString());
    });

    _loadPosts();

    UserUtils.checkRoleMP(this, widget);
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
        UserUtils.decodeImagesMP(widget, posts, achievements);
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
        UserUtils.decodeImagesMP(widget, posts, achievements);
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


  Future<List<Achievement>> getAchievements(Author author) async {
    int userId = author.userId;
    return ActionUtils.getAchievements('https://greenhubapp.ru:80/users/$userId/achievements');
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
                    AppMetrica.reportEvent('Click on "Edit profile" button');
                    _showEditProfileDialog();
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5fc16f),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: const Color(0xFF333333)),
                            SizedBox(width: 2),
                            Text('Редактировать', style: TextStyle(color: const Color(0xFF333333), fontFamily: 'Roboto', fontSize: 18)),
                          ],
                        ),
                      )
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    AppMetrica.reportEvent('Click on "Quit" button');
                    TokenStorage.clearToken();
                    TokenStorage.clearRole();
                    TokenStorage.clearUsername();
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app, color: const Color(0xFF333333)),
                          SizedBox(width: 2),
                          Text('Выйти', style: TextStyle(color: const Color(0xFF333333), fontFamily: 'Roboto', fontSize: 18)),
                        ],
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsWidget() {
    return InkWell(
      onTap: () {
        if (widget.role!) {
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
              Author? author = await UserUtils.fetchAuthorByUsername(widget.author.username);
              if (author != null) {
                Navigator.pushReplacement(
                  context,
                  CustomPageRoute(page: Profile(author: author)),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  CustomPageRoute(page: Profile(author: widget.author)),
                );
              }
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
                if ((post.image != null) && (post.image != '') && (post.decodedImage != null))
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
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
                                AppMetrica.reportEvent(
                                    'Click on "Like" button');

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
                                AppMetrica.reportEvent(
                                    'Click on "Dislike" button');
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
      code = await ActionUtils.sendReaction(post.id, reactionType);
    } else {
      code = await ActionUtils.deleteReaction(post.id);
    }
    return code;
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

  // Метод для открытия галереи и выбора изображения
  Future<void> _pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await xFileToBytes(pickedImage);
      setState(() {
        widget._pickedImage = pickedImage;
        widget._pickedImageBytes = bytes;
      });
    }
  }

  Future<Uint8List> xFileToBytes(XFile xFile) async {
    return await xFile.readAsBytes();
  }

  void _showEditProfileDialog() {
    TextEditingController emailController = TextEditingController(text: widget.author.email);

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
                        image: widget._pickedImageBytes == null
                            ? MemoryImage(base64.decode(widget.author.userImage))
                            : MemoryImage(widget._pickedImageBytes!),
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
                        onPressed: () async {
                          // Действия при нажатии на карандаш
                          await _pickImageFromGallery(); // Дождитесь выбора изображения
                          Navigator.pop(context); // Закрыть диалоговое окно
                          _showEditProfileDialog(); // Повторно отобразить диалоговое окно для обновления картинки
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
                onPressed: () async {
                  if (emailController.text.length > 49) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Ошибка'),
                          content: Text('Длина Email не должна превышать 50 символов'),
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
                  } else {
                    if (widget._pickedImageBytes != null) {
                      var code = await PublicationUtils.setImageAndEmail(widget.author.userId, widget._pickedImage!, emailController.text);
                      if (code == 200) {
                        setState(() {
                          widget.decodedAvatar = widget._pickedImageBytes;
                          widget.author.email = emailController.text;
                        });
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Ошибка'),
                              content: Text('Ошибка'),
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
                    } else {
                      await ActionUtils.setEmail(widget.author.userId, emailController.text);
                      widget.author.email = emailController.text;
                    }
                    Navigator.of(context).pop();
                  }
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

  Future<void> getAllAchievements() async {
    allAchievements = await ActionUtils.getAchievements('https://greenhubapp.ru:80/users/achievements');
  }
}