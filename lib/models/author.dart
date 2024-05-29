class Author {
    final int userId;
    final String userImage;
    final String username;
    final bool? subscribed;
    String? email;
    int? subscriptionsCount;
    int? subscribersCount;
    String? state;
    String? role;

    Author({
      required this.username,
      required this.userImage,
      required this.userId,
      this.subscribersCount,
      this.subscriptionsCount,
      this.email,
      this.subscribed,
      this.state,
      this.role,
    });

    factory Author.fromJson(Map<String, dynamic> json) {
      List<dynamic>? rolesJson = json['roles'];
      String? role;
      if (rolesJson != null && rolesJson.isNotEmpty) {
        final Map<String, dynamic> roleMap = rolesJson.first;
        role = roleMap['name'];
      }
      return Author(
        role: role,
        state: json['state'],
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