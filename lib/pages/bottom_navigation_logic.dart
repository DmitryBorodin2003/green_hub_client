import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:green_hub_client/pages/lenta.dart';
import 'package:green_hub_client/pages/subscriptions.dart';

import '../post.dart';
import 'createpost.dart';
import 'custom_page_route.dart';
import 'my_profile.dart';

class BottomNavigationLogic {
  static void handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        AppMetrica.reportEvent('Click on "Lenta" button');
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
            page: Lenta(
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
        AppMetrica.reportEvent('Click on "New post" button');
      // Действия при выборе создания поста
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
            page: Createpost(),
          ),
        );
        break;
      case 2:
        AppMetrica.reportEvent('Click on "Subscriptions" button');
      // Действия при выборе страницы подписок
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
            page: Subscriptions(
              subscriptionList: [
                User(name: 'Леонардо'),
                User(name: 'Андрей'),
                User(name: 'Вячеслав'),
                User(name: 'Александр')
              ],
              followerList: [User(name: 'Андрей')],
            ),
          ),
        );
        break;
      case 3:
        AppMetrica.reportEvent('Click on "My profile" button');
        // Действия при выборе профиля
        Navigator.pushReplacement(
          context,
          CustomPageRoute(
            page: Profile(
              posts: [
                Post(
                  content: 'Мы открыли новый центр переработки! Ждем всех!',
                  title: 'Новый центр переработки!',
                  username: 'Райан',
                  rating: 92,
                  tags: ['#Мусор', '#Воронеж'],
                  avatarUrl: 'https://i.pinimg.com/originals/2b/64/2f/2b642f9183fa80b8c47a9d8f8971eb4d.jpg',
                  imageUrl:
                  'https://iq.vgoroden.ru/qs07ga0ow6io7_1f4ej61/krupneyshiy-v-rossii-musorosortirovochnyy-kompleks-otkrylsya-v-nizhegorodskoy-oblasti-foto-foto-8.jpeg',
                ),
                Post(
                  content: 'Она как для мясоедов только без мяса',
                  title: 'Новая реклама веганской еды!',
                  username: 'Райан',
                  avatarUrl: 'https://i.pinimg.com/originals/2b/64/2f/2b642f9183fa80b8c47a9d8f8971eb4d.jpg',
                  rating: 100500,
                  tags: ['#Еда', '#Хавка'],
                )
              ],
            ),
          ),
        );
        break;
      default:
    }
  }
}
