import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/lenta.dart';

import '../post.dart';

class BottomNavigationLogic {
  static void handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Lenta(
              posts: [
                Post(
                    content: 'Сегодня мы с командой убрали мусор на берегах водохранилища!',
                    title: 'Отчет об уборке мусора',
                    username: 'Грета',
                    avatarUrl: 'https://s0.rbk.ru/v6_top_pics/media/img/0/61/755695733019610.png',
                    rating: 100,
                    tags: ['#Уборка', '#Воронеж', '#Мусор'],
                    imageUrl: 'https://vremenynet.ru/image_3814.png'),
                Post(
                  content: 'Уличные животные тоже хотят еды и тепла. Пожалуйста, помогайте нам!',
                  title: 'Не забывайте нас!',
                  username: 'Мистер Кот',
                  avatarUrl: 'https://static5.tgstat.ru/channels/_0/af/af18c25836a1cac48b3e857f96911013.jpg',
                  rating: 200,
                  tags: ['#Животные', '#Кот'],
                )
              ],
            ),
          ),
        );
        break;
      case 1:
      // Действия при выборе создания поста
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Создание поста'),
              content: Text('Здесь будет меню создания поста'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Закрыть'),
                ),
              ],
            );
          },
        );
        break;
      case 2:
      // Действия при выборе страницы подписок
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Страница подписок'),
              content: Text('Здесь будет переход на страницу подписок/подписчиков'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Закрыть'),
                ),
              ],
            );
          },
        );
        break;
      case 3:
      // Действия при выборе профиля
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Страница профиля'),
              content: Text('Здесь будет переход на страницу профиля'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Закрыть'),
                ),
              ],
            );
          },
        );
        break;
      default:
    }
  }
}
