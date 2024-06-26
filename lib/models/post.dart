import 'dart:typed_data';

import 'author.dart';

class Post {
  int rating;
  final String title;
  final List<String> tags;
  final String text;
  final String image;
  final Author author;
  final int id;
  String reactionType;
  bool hidden;
  Uint8List? decodedImage;
  Uint8List? decodedAvatar;
  String createdTime;

  Post({
    required this.id,
    required this.title,
    required this.text,
    required this.author,
    required this.image,
    required this.rating,
    required this.createdTime,
    required this.tags,
    this.reactionType = 'null',
    this.hidden = false, // По умолчанию пост не скрыт
    this.decodedImage,
    this.decodedAvatar,
  });
}