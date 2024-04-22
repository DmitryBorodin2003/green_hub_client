class Post {
  final String username;
  final String title;
  final String content;
  final String? imageUrl;
  final String? avatarUrl;
  final int rating;
  final List<String> tags;

  Post({
    required this.username,
    required this.title,
    required this.content,
    this.avatarUrl,
    this.imageUrl,
    required this.rating,
    required this.tags,
  });
}