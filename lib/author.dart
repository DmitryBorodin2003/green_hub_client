  class Author {
    final int userId;
    final String userImage;
    final String username;

    Author({
      required this.username,
      required this.userImage,
      required this.userId,
    });

    factory Author.fromJson(Map<String, dynamic> json) {
      return Author(
        userId: json['id'],
        userImage: json['image'],
        username: json['username'],
      );
    }

    factory Author.fromJson2(Map<String, dynamic> json) {
      return Author(
        userId: json['userId'],
        userImage: json['userImage'],
        username: json['username'],
      );
    }
  }