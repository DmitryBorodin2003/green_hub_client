import 'dart:convert';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../publication_utils.dart';
import '../token_storage.dart';
import 'bottom_navigation_bar.dart';
import 'bottom_navigation_logic.dart';
import 'package:http/http.dart' as http;

import 'custom_page_route.dart';
import 'lenta.dart';

class Createpost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreatePostState();
  }
}

class _CreatePostState extends State {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _textController = TextEditingController();
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
  String _selectedTagsText = ''; // Поле для отображения выбранных тегов
  XFile? _pickedImage; // Переменная для хранения выбранного изображения
  bool _isButtonDisabled = false;

  // Функция для открытия галереи и выбора изображения
  Future<void> _pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
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
                textAlign: TextAlign.center,
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
                      FocusScope.of(context).unfocus();
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

  bool _validateTitle(String value) {
    if (value.length > 20) {
      return false;
    }
    return true;
  }

  bool _validateText(String value) {
    if (value.length > 255) {
      return false;
    }
    return true;
  }

  // Функция для обработки нажатия на кнопку "Добавить"
  Future<void> _onAddButtonPressed() async {
    AppMetrica.reportEvent('Click on "Add post" button');

    setState(() {
      _isButtonDisabled = true;
    });
    if (_titleController.text.length == 0 || _textController.text.length == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ошибка'),
            content: Text('Поля не должны быть пустыми'),
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
    } else {
      if (_validateTitle(_titleController.text)) {
        if (_validateText(_textController.text)) {
          var code;
          if (_pickedImage != null) {
            code = await PublicationUtils.postData(_titleController.text, _textController.text, _selectedTags, _pickedImage!);
          } else {
            code = await PublicationUtils.postDataWithoutPicture(_titleController.text, _textController.text, _selectedTags);
          }
          print(code);
          if (code == 201) {
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                  page: Lenta()),
            );
          } else if (code == 413) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Ошибка'),
                  content: Text('Размер загружаемого изображения не должен превышать 10Мб'),
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
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Ошибка'),
                  content: Text('Ошибка при отправке данных'),
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
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Ошибка'),
                content: Text('Текст публикации не должен быть длиннее 256 символов'),
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
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ошибка'),
              content: Text('Заголовок не должен быть длиннее 20 символов'),
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
      }
    }

    setState(() {
      _isButtonDisabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCFED7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Color(0xFFDCFED7),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            'Добавить публикацию',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            height: 2.0,
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Заголовок',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Введите текст...',
                          contentPadding: EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Текст публикации',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Введите текст...',
                          contentPadding: EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Выберите фото',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: _pickedImage != null ? _pickedImage!.name : '📎 Загрузить фото',
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Выберите теги',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    InkWell(
                      onTap: () {
                        _showTagSelectionDialog().then((value) {
                          setState(() {
                            // Обновляем текст виджета с выбранными тегами через запятую
                            _selectedTagsText = _selectedTags.join(', ');
                          });
                        });
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          _selectedTagsText.isNotEmpty ? _selectedTagsText : '# Теги',
                          style: TextStyle(
                            color: _selectedTagsText.isNotEmpty ? Colors.grey : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: _isButtonDisabled ? null : _onAddButtonPressed,
                  child: Text(
                    'Добавить',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 70.0, vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          BottomNavigationLogic.handleNavigation(context, index);
        },
      ),
    );
  }
}
