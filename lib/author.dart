class Author {
    final int userId;
    final String userImage;
    final String username;
    final bool? subscribed;

    Author({
      required this.username,
      required this.userImage,
      required this.userId,
      this.subscribed,
    });

    factory Author.fromJson(Map<String, dynamic> json) {
      return Author(
        subscribed: json['subscribed'],
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