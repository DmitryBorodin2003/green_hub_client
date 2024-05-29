class Comment {
  final int id;
  final String text;
  final String authorName;
  final String authorImage;

  Comment({
    required this.id,
    required this.text,
    required this.authorName,
    required this.authorImage,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      text: json['text'] as String,
      authorName: json['authorName'] as String,
      authorImage: json['authorImage'] as String,
    );
  }
}