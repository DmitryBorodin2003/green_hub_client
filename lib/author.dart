class Author {
    final int userId;
    final String userImage;
    final String username;
    final bool? subscribed;
    final String? email;
    int? subscriptionsCount;
    int? subscribersCount;

    Author({
      required this.username,
      required this.userImage,
      required this.userId,
      this.subscribersCount,
      this.subscriptionsCount,
      this.email,
      this.subscribed,
    });

    factory Author.fromJson(Map<String, dynamic> json) {
      return Author(
        subscribersCount: json['subscribersCount'],
        subscriptionsCount: json['subscriptionsCount'],
        email: json['email'],
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