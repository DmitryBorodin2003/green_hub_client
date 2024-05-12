class Achievement {
  final int id;
  final String image;
  final String name;

  Achievement({
    required this.id,
    required this.image,
    required this.name,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as int,
      image: json['image'] as String,
      name: json['name'] as String,
    );
  }
}