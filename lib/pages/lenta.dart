import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/profile.dart';
import 'package:green_hub_client/utilities/publication_utils.dart';
import 'package:green_hub_client/storages/token_storage.dart';
import 'package:green_hub_client/models/post.dart';
import 'package:green_hub_client/models/author.dart';
import '../storages/user_credentials.dart';
import 'package:green_hub_client/bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:green_hub_client/bottom_navigation_bar/bottom_navigation_logic.dart';
import '../utilities/action_utils.dart';
import '../utilities/user_utils.dart';
import 'comments.dart';
import 'package:green_hub_client/utilities/custom_page_route.dart';
import 'login.dart';
import 'my_profile.dart';

  class Lenta extends StatefulWidget {
    bool? role = false;
    Null array;
  
    @override
    _LentaState createState() => _LentaState();
  }
  
  class _LentaState extends State<Lenta> with TickerProviderStateMixin {
    late TabController _tabController;
    late ScrollController _scrollController;
    double _scrollPosition = 0.0;
  
    int? selectedOptionIndex;
    List<String> _selectedTags = [];
    List<String> _availableTags = [
      'Воронеж',
      'Мусор',
      'Субботник',
      'Животные',
      'Природа',
      'Здоровье',
      'Саморазвитие',
    ];
    List<Post> _posts = [];
    List<Post> _personalPosts = [];
    bool _isLoading = true;
    bool _isLoadingMore = false;
    int _currentPage = 0;
    int _totalPages = 1;
    int _personalCurrentPage = 0;
    int _personalTotalPages = 1;
  
    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 2, vsync: this);
      _scrollController = ScrollController();
      _loadPosts();
      _tabController.index = 0;
      selectedOptionIndex = 0;

      _tabController.addListener(() async {
        if (_tabController.index == 1 && _personalPosts.isEmpty) {
          if (await TokenStorage.getToken() == null) {
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                page: Login(),
              ),
            );
          } else {
            _scrollPosition = 0;
            _loadPosts();
          }
        }
        _scrollToTop();
      });
    }

    Future<void> _loadPosts({bool loadMore = false}) async {
      if (_isLoadingMore) return;
      setState(() {
        if (loadMore) {
          _isLoadingMore = true;
        } else {
          _isLoading = true;
        }
        print("setState loading: $_isLoadingMore");
      });

      int size = 10;
      String url;
      if (_tabController.index == 0) {
        url = 'https://greenhubapp.ru:80/publications?page=$_currentPage&size=$size';
      } else {
        url = 'https://greenhubapp.ru:80/publications/subscriptions?page=$_personalCurrentPage&size=$size';
      }
      print("Fetching from URL: $url");

      var token = await TokenStorage.getToken();
      Map<String, dynamic> response;

      if (token != null) {
        response = await PublicationUtils.fetchPublications(url, context);
      } else {
        response = await PublicationUtils.fetchPublicationsWithoutToken(url, context);
      }

      List<Post> newPosts = response['posts'] as List<Post>;
      print("Fetched ${newPosts.length} posts");

      if (_tabController.index == 0) {
        _totalPages = response['totalPages'];
      } else {
        _personalTotalPages = response['totalPages'];
      }

      setState(() {
        if (loadMore) {
          _scrollPosition = _scrollController.position.pixels;
          if (_tabController.index == 0) {
            _posts.addAll(newPosts);
          } else {
            _personalPosts.addAll(newPosts);
          }
        } else {
          if (_tabController.index == 0) {
            _posts = newPosts;
          } else {
            _personalPosts = newPosts;
          }
        }
        _isLoading = false;
        _isLoadingMore = false;
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollPosition);
          }
        });
      });

      decodeImages();
      checkRole();
    }

    void _scrollToTop() {
      _scrollController.jumpTo(0.0);
    }

    void _loadMorePosts() async {
      if (_tabController.index == 0) {
        if (_currentPage < _totalPages - 1) {
          setState(() {
            _currentPage++;
          });
          await _loadPosts(loadMore: true);
        }
      } else {
        if (_personalCurrentPage < _personalTotalPages - 1) {
          setState(() {
            _personalCurrentPage++;
          });
          await _loadPosts(loadMore: true);
        }
      }
    }
  
    int? findPostIndex(Post post, List<Post> postList) {
      for (int i = 0; i < postList.length; i++) {
        if (postList[i].id == post.id) {
          return i;
        }
      }
      return null;
    }
  
    List<Post> getOppositeArray(List<Post> array) {
      var arr;
      if (array == _posts) {
        arr = _personalPosts;
      }
      else if (array == _personalPosts) {
        arr = _posts;
      }
      return arr;
    }
  
    void decodeImages() {
      for (var post in _posts) {
        post.decodedAvatar = base64.decode(post.author.userImage);
        post.decodedImage = base64.decode(post.image);
      }
      for (var post in _personalPosts) {
        post.decodedAvatar = base64.decode(post.author.userImage);
        post.decodedImage = base64.decode(post.image);
      }
    }
  
  
    Future<void> _showTagSelectionDialog() async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Color(0xFFDCFED7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                title: Text(
                  'Выберите теги',
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
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
                shape: RoundedRectangleBorder(
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
                      height: 1,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    RadioListTile<int>(
                      value: 0,
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
                          color: selectedOptionIndex == 0
                              ? Colors.green
                              : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    RadioListTile<int>(
                      value: 1,
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
                        Navigator.of(context).pop();
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
                  SizedBox(height: 10),
                ],
              );
            },
          );
        },
      );
    }
  
    void _sortPosts() {
      if (selectedOptionIndex == 1) {
        _posts.sort((a, b) => b.rating.compareTo(a.rating));
        _personalPosts.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (selectedOptionIndex == 0) {
        _posts.sort((a, b) => b.createdTime.compareTo(a.createdTime));
        _personalPosts.sort((a, b) => b.createdTime.compareTo(a.createdTime));
      }
  
      setState(() {});
      print("setstate на строке 325");
    }
  
    void _applyTagFilter() {
      if (_selectedTags.isEmpty) {
        setState(() {
          _selectedTags.clear();
          for (var post in _posts) {
            post.hidden = false;
          }
          for (var post in _personalPosts) {
            post.hidden = false;
          }
        });
        return;
      }
  
      setState(() {
        for (var post in _posts) {
          if (post.tags.every((tag) => !_selectedTags.contains(tag))) {
            post.hidden = true;
          } else {
            post.hidden = false;
          }
        }
        for (var post in _personalPosts) {
          if (post.tags.every((tag) => !_selectedTags.contains(tag))) {
            post.hidden = true;
          } else {
            post.hidden = false;
          }
        }
      });
    }
  
  
    @override
    Widget build(BuildContext context) {
      return DefaultTabController(
       length: 2,
       child: Scaffold(
         backgroundColor: Color(0xFFDCFED7),
         appBar: AppBar(
           automaticallyImplyLeading: false,
           backgroundColor: Color(0xFFDCFED7),
           toolbarHeight: 125,
           title: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Padding(
                 padding: EdgeInsets.only(top: 16),
                 child: Row(
                   children: [
                     SizedBox(
                       height: 60,
                       child: Image.asset(
                         'assets/logofullhorizontal2.png',
                         height: 20,
                       ),
                     ),
                     Spacer(),
                     IconButton(
                       icon: Icon(Icons.arrow_upward),
                       onPressed: () {
                         AppMetrica.reportEvent('Click on "Sort" button');
                         _showSortOptionsDialog();
                       },
                       color: Colors.black,
                     ),
                     IconButton(
                       icon: Icon(Icons.filter_list),
                       onPressed: () {
                         AppMetrica.reportEvent('Click on "Filter" button');
                         _showTagSelectionDialog();
                       },
                       color: Colors.black,
                     ),
                   ],
                 ),
               ),
               TabBar(
                 controller: _tabController,
                 tabs: [
                   Tab(
                     child: FittedBox(
                       fit: BoxFit.scaleDown,
                       child: Text(
                         'Лента',
                         style: TextStyle(
                           fontSize: 25,
                         ),
                       ),
                     ),
                   ),
                   Tab(
                     child: FittedBox(
                       fit: BoxFit.scaleDown,
                       child: Text(
                         'Подписки',
                         style: TextStyle(
                           fontSize: 25,
                         ),
                       ),
                     ),
                   ),
                 ],
                 indicator: UnderlineTabIndicator(
                   borderSide: BorderSide(
                       width: 2.0, color: Colors.green),
                 ),
                 labelColor: Colors.black,
                 labelStyle: TextStyle(fontSize: 16),
               ),
             ],
           ),
         ),
           body: _isLoading
               ? Center(child: CircularProgressIndicator())
               : TabBarView(
             controller: _tabController,
             children: [
               _buildPostList(_posts),
               _buildPostList(_personalPosts),
             ],
           ),
  
  
         bottomNavigationBar: CustomBottomNavigationBar(
           onTap: (index) {
             BottomNavigationLogic.handleNavigation(context, index);
           },
         ),
       ),
      );
    }

    Widget _buildPostList(List<Post> posts) {
      //TODO проверка исчезла на пустоту
      return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadMorePosts();
          return true;
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return buildPostCard(context, posts, posts[index], index, Key('${posts[index].id}_$index'));
        },
      ));
    }
  

    Widget buildPostCard(BuildContext context, List<Post> array, Post post, int index, Key key) {
      if (post.hidden) {
        return SizedBox.shrink();
      }
      return Card(
        key: key,
        color: const Color(0xFFf5fff3),
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
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppMetrica.reportEvent(
                              'Click on "Not my profile" button');
                          fetchDataAndNavigate(context, array, index);
                        },
                        child: ClipOval(
                          child: Image.memory(
                            post.decodedAvatar!,
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
                  if ((post.image != null) && (post.image != '') &&
                      (post.decodedImage != null))
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
                                  if (await TokenStorage.getToken() != null) {
                                    var secondArray = getOppositeArray(array);
                                    var x = findPostIndex(post, secondArray);
                                    var code = await handleReaction(post, 'LIKE');
                                    setState(() {
                                      array[index] = post;
                                      if (x != null) {
                                        secondArray[x] = post;
                                      }
                                    });
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      CustomPageRoute(
                                        page: Login(),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: post.reactionType == 'LIKE'
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  AppMetrica.reportEvent(
                                      'Click on "Dislike" button');
                                  if (await TokenStorage.getToken() != null) {
                                    var secondArray = getOppositeArray(array);
                                    var x = findPostIndex(post, secondArray);
                                    var code = await handleReaction(post, 'DISLIKE');
                                    //TODO обработка кода успешного лайка дизлайка
                                    setState(() {
                                      array[index] = post;
                                      if (x != null) {
                                        secondArray[x] = post;
                                      }
                                    });
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      CustomPageRoute(
                                        page: Login(),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.thumb_down,
                                  color: post.reactionType == 'DISLIKE' ? Colors
                                      .blue : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () async {
                          AppMetrica.reportEvent(
                              'Click on "Comments" button');
                          if (await TokenStorage.getToken() != null) {
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                page: Comments(postId: post.id,),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                page: Login(),
                              ),
                            );
                          }
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
                  SizedBox(height: 16),
                ],
              ),
              Visibility(
                visible: widget.role!,
                child: Positioned(
                  top: 0,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(index, array);
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
    }

  Future<void> checkRole() async {
    String? role = await TokenStorage.getRole();
    setState(() {
      widget.role = role == 'ROLE_ADMIN' || role == 'ROLE_MODERATOR';
    });
  }

  // Метод для показа диалогового окна удаления поста
  void _showDeleteConfirmationDialog(int index, List<Post> arr) {
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
                _deletePost(index, arr); // Удаляем пост
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
  void _deletePost(int index, List<Post> arr) async {
    try {
      var code = await PublicationUtils.deletePost(arr[index].id);
      var secondArray = getOppositeArray(arr);
      var x = findPostIndex(arr[index], secondArray);
      if (code == 204) {
        setState(() {
          arr.removeAt(index);
          if (x != null) {
            secondArray.removeAt(x);
          }
        });
      } else {
        print('Ошибка при удалении публикации: ${code}');
      }
    } catch (e) {
      print('Произошла ошибка при удалении публикации: $e');
    }
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

  Future<void> fetchDataAndNavigate(BuildContext context, List<Post> array, int index) async {
    if (await TokenStorage.getToken() != null) {
      try {
        Author? author = await UserUtils.fetchAuthorByUsername(array[index].author.username);
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
    } else {
      Navigator.push(
        context,
        CustomPageRoute(
          page: Login(),
        ),
      );
    }
  }
}
