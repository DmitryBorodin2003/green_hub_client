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

  Post({
    required this.id,
    required this.title,
    required this.text,
    required this.author,
    required this.image,
    required this.rating,
    required this.tags,
    this.reactionType = 'null',
  });
}