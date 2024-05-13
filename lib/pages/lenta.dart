import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/profile.dart';
import 'package:green_hub_client/publication_utils.dart';

import '../../post.dart';
import '../author.dart';
import '../user_credentials.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'comments.dart';
import 'custom_page_route.dart';
import 'package:http/http.dart' as http;

import 'my_profile.dart';

class Lenta extends StatefulWidget {
  final List<Post> posts; // Список постов
  final List<Post> personal_posts;
  Null array;

  Lenta({required this.posts, required this.personal_posts});

  @override
  _LentaState createState() => _LentaState();
}

class _LentaState extends State<Lenta> with TickerProviderStateMixin {
  late TabController _tabController;
  int? selectedOptionIndex; // Индекс выбранной опции сортировки
  List<String> _selectedTags = [];
  List<String> _availableTags = [
    'Воронеж',
    'Мусор',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0; // Устанавливаем активную вкладку по умолчанию
    selectedOptionIndex = 0; // При инициализации выбора нет
    _sortPosts();
  }

  int? findPostIndex(Post post, List<Post> postList) {
    for (int i = 0; i < postList.length; i++) {
      if (postList[i].id == post.id) {
        return i;
      }
    }
    return null; // Возвращаем null, если пост не найден
  }


  Future<void> _showTagSelectionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFDCFED7),
              // Цвет фона окна
              shape: RoundedRectangleBorder(
                // Скругление углов
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text(
                'Выберите теги',
                textAlign: TextAlign.center, // Центрирование заголовка
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1, // Серая полоска
                    color: Colors.grey,
                  ),
                  ..._availableTags.map((tag) {
                    bool isSelected = _selectedTags.contains(tag);
                    return CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text('#$tag'),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected ?? false) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _applyTagFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 15.0),
                    ),
                    child: Text('ОК'),
                  ),
                ),
                SizedBox(height: 10), // Добавленное расстояние
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _showSortOptionsDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFDCFED7),
              // Цвет фона окна
              shape: RoundedRectangleBorder(
                // Скругление углов
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text(
                'Сортировка',
                textAlign: TextAlign.center, // Центрирование заголовка
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1, // Серая полоска
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  // Первая опция сортировки: По количеству лайков
                  RadioListTile<int>(
                    value: 0,
                    groupValue: selectedOptionIndex,
                    onChanged: (int? value) {
                      setState(() {
                        selectedOptionIndex = value;
                      });
                    },
                    title: Text(
                      'По количеству лайков',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedOptionIndex == 0
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Вторая опция сортировки: По свежести
                  RadioListTile<int>(
                    value: 1,
                    groupValue: selectedOptionIndex,
                    onChanged: (int? value) {
                      setState(() {
                        selectedOptionIndex = value;
                      });
                    },
                    title: Text(
                      'По свежести',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedOptionIndex == 1
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Закрываем диалоговое окно
                      _sortPosts();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 15.0),
                    ),
                    child: Text('ОК'),
                  ),
                ),
                SizedBox(height: 10), // Добавленное расстояние
              ],
            );
          },
        );
      },
    );
  }

  void _sortPosts() {
    if (selectedOptionIndex == 0) {
      // Сортировка по количеству лайков
      widget.posts.sort((a, b) => b.rating.compareTo(a.rating));
      widget.personal_posts.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedOptionIndex == 1) {
      //TODO: сортировка по свежести
      //widget.posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      //widget.personal_posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      widget.posts.sort((a, b) => a.rating.compareTo(b.rating));
      widget.personal_posts.sort((a, b) => a.rating.compareTo(b.rating));
    }

    // Обновление экрана после сортировки
    setState(() {});
  }

  void _applyTagFilter() {
    if (_selectedTags.isEmpty) {
      // Если ни один тег не выбран, показываем все посты
      setState(() {
        // Очищаем выбранные теги
        _selectedTags.clear();
        // Помечаем все посты как не скрытые
        for (var post in widget.posts) {
          post.hidden = false;
        }
        for (var post in widget.personal_posts) {
          post.hidden = false;
        }
      });
      return;
    }

    setState(() {
      // Фильтруем посты по выбранным тегам
      for (var post in widget.posts) {
        if (post.tags.every((tag) => !_selectedTags.contains(tag))) {
          post.hidden = true; // Помечаем пост как скрытый
        } else {
          post.hidden = false; // Помечаем пост как не скрытый
        }
      }
      for (var post in widget.personal_posts) {
        if (post.tags.every((tag) => !_selectedTags.contains(tag))) {
          post.hidden = true; // Помечаем пост как скрытый
        } else {
          post.hidden = false; // Помечаем пост как не скрытый
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCFED7), // Цвет фона
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFDCFED7), // Цвет фона апп-бара
        toolbarHeight: 125, // Увеличиваем высоту апп-бара
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16), // Добавляем отступ сверху
              child: Row(
                children: [
                  SizedBox(
                    height: 60, // Уменьшаем высоту логотипа
                    child: Image.asset(
                      'assets/logofullhorizontal2.png',
                      height: 20, // Уменьшаем размер логотипа
                    ),
                  ),
                  SizedBox(width: 30), // Промежуток между логотипом и кнопками
                  IconButton(
                    icon: Icon(Icons.arrow_upward), // Значок стрелочки
                    onPressed: () {
                      AppMetrica.reportEvent('Click on "Sort" button');
                      _showSortOptionsDialog();
                    },
                    color: Colors.black, // Устанавливаем цвет иконки
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list), // Значок фильтра
                    onPressed: () {
                      AppMetrica.reportEvent('Click on "Filter" button');
                      _showTagSelectionDialog();
                    },
                    color: Colors.black, // Устанавливаем цвет иконки
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Text(
                    'Лента',
                    style: TextStyle(
                      fontSize: 25, // Увеличиваем размер текста
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Подписки',
                    style: TextStyle(
                      fontSize: 25, // Увеличиваем размер текста
                    ),
                  ),
                ),
              ],
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                    width: 2.0, color: Colors.green), // Зелёное подчёркивание
              ),
              labelColor: Colors.black,
              labelStyle: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Содержимое для вкладки "Лента"
          ListView.builder(
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              return buildPostCard(context, widget.posts, post, index);
            },
          ),

          // Содержимое для вкладки "Подписки"
          ListView.builder(
            itemCount: widget.personal_posts.length,
            itemBuilder: (context, index) {
              final post = widget.personal_posts[index];
              return buildPostCard(context, widget.personal_posts, post, index);
            },
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

  Widget buildPostCard(BuildContext context, List<Post> array, Post post, int index) {
    if (post.hidden) {
      return SizedBox.shrink();
    }
    return Card(
      color: const Color(0xFFf5fff3),
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
              children: [
                GestureDetector(
                  onTap: () {
                    AppMetrica.reportEvent(
                        'Click on "Not my profile" button');
                    fetchDataAndNavigate(context, array, index);
                  },
                  child: ClipOval(
                    child: Image.memory(
                      base64.decode(post.author.userImage),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    AppMetrica.reportEvent(
                        'Click on "Not my profile" button');
                    fetchDataAndNavigate(context, array, index);
                  },
                  child: Text(
                    post.author.username,
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
            SizedBox(height: 15),
            Text(
              post.title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 25),
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
                            AppMetrica.reportEvent(
                                'Click on "Like" button');
                            var arr;
                            if (array == widget.posts) {
                              arr = widget.personal_posts;
                            }
                            else if (array == widget.personal_posts) {
                              arr = widget.posts;
                            } else arr = null;
                            var x = findPostIndex(post, arr);

                            handleReaction(post, 'LIKE');
                            setState(() {
                              array[index] = post;
                              if ((arr != null) && (x != null)) {
                                arr[x] = post;
                              }
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
                            var arr;
                            if (array == widget.posts) {
                              arr = widget.personal_posts;
                            }
                            else if (array == widget.personal_posts) {
                              arr = widget.posts;
                            } else arr = null;
                            var x = findPostIndex(post, arr);
                            handleReaction(post, 'DISLIKE');
                            setState(() {
                              array[index] = post;
                              if ((arr != null) && (x != null)) {
                                arr[x] = post;
                              }
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
                    AppMetrica.reportEvent(
                        'Click on "Comments" button');
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
    if (post.reactionType != 'null') {
      PublicationUtils.sendReaction(post.id, reactionType);
    } else {
      PublicationUtils.deleteReaction(post.id);
    }

  }

  Future<void> fetchDataAndNavigate(BuildContext context, List<Post> array, int index) async {
    try {
      Author? author = await PublicationUtils.fetchAuthorByUsername(array[index].author.username);
      if (author != null) {
        if (author.username != UserCredentials().username) {
          Navigator.pushReplacement(
            context,
            CustomPageRoute(page: NotMyProfile(author: author)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            CustomPageRoute(page: Profile(author: author)),
          );
        }
      } else {
        // Обработка случая, когда пользователь не найден или произошла ошибка
        print('Пользователь с таким именем не найден');
      }
    } catch (e) {
      // Обработка ошибок
      print('Произошла ошибка: $e');
    }
  }
}
