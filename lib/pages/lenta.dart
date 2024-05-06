import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/profile.dart';

import '../../post.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'comments.dart';
import 'custom_page_route.dart';

class Lenta extends StatefulWidget {
  final List<Post> posts; // Список постов

  Lenta({required this.posts});

  @override
  _LentaState createState() => _LentaState();
}

class _LentaState extends State<Lenta> with TickerProviderStateMixin {
  late TabController _tabController;
  int? selectedOptionIndex; // Индекс выбранной опции сортировки
  List<String> _selectedTags = [];
  List<String> _availableTags = [
    '#Воронеж',
    '#Уборка',
    '#Мусор',
    '#Животные',
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0; // Устанавливаем активную вкладку по умолчанию
    selectedOptionIndex = 0; // При инициализации выбора нет
  }

  Future<void> _showTagSelectionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFDCFED7), // Цвет фона окна
              shape: RoundedRectangleBorder( // Скругление углов
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
                      title: Text(tag),
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
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
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
              backgroundColor: Color(0xFFDCFED7), // Цвет фона окна
              shape: RoundedRectangleBorder( // Скругление углов
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
                        color: selectedOptionIndex == 0 ? Colors.green : Colors.black,
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
                        color: selectedOptionIndex == 1 ? Colors.green : Colors.black,
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
                      // логика сортировки на основе выбранной опции
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
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
                      _showSortOptionsDialog();
                    },
                    color: Colors.black, // Устанавливаем цвет иконки
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list), // Значок фильтра
                    onPressed: () {
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
                borderSide: BorderSide(width: 2.0, color: Colors.green), // Зелёное подчёркивание
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
                          post.avatarUrl != null
                              ? GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  CustomPageRoute(
                                    page: NotMyProfile(posts: [
                                      Post(
                                      content: 'Сегодня мы с командой убрали мусор на берегах водохранилища!',
                                      title: 'Отчет об уборке мусора',
                                      username: 'Грета',
                                      avatarUrl: 'https://s0.rbk.ru/v6_top_pics/media/img/0/61/755695733019610.png',
                                      rating: 100,
                                      tags: ['#Уборка', '#Воронеж', '#Мусор'],
                                      imageUrl: 'https://vremenynet.ru/image_3814.png'),
                                      Post(
                                      content: 'Я Грета Тунберг, теперь буду здесь делиться с вами важной информацией',
                                      title: 'Здравствуйте!',
                                      username: 'Грета',
                                      avatarUrl: 'https://s0.rbk.ru/v6_top_pics/media/img/0/61/755695733019610.png',
                                      rating: 200,
                                      tags: ['#Уборка', '#Чистота'],
                                      )
                              ]
                              ),
                              ),
                              );
                            },
                            child: ClipOval(
                              child: Image.network(
                                post.avatarUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              ),
                            ),
                          )
                              : GestureDetector(
                            onTap: () {
                              // Handle avatar click action here
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey,
                              child: Text(post.username[0]),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // Handle username click action here
                            },
                            child: Text(
                              post.username,
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        post.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      SizedBox(height: 15),
                      Text(post.content, style: TextStyle(fontSize: 18),),
                      SizedBox(height: 15),
                      // Вставляем изображение после контента
                      if (post.imageUrl != null) Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7), // Применяем скругление углов
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7), // Применяем скругление углов
                          child: Image.network(
                            post.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Отображаем рейтинг поста слева от кнопок лайка и дизлайка
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
                                    onPressed: () {},
                                    icon: Icon(Icons.thumb_up),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.thumb_down),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
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

          // Содержимое для вкладки "Подписки"
          Center(
            child: Text('Здесь будет содержимое вкладки "Подписки"'),
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
}
