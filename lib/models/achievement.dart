import 'dart:typed_data';

class Achievement {
  final int id;
  final String image;
  final String name;
  Uint8List? decodedImage;

  Achievement({
    required this.id,
    required this.image,
    required this.name,
    this.decodedImage,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as int,
      image: json['image'] as String,
      name: json['name'] as String,
    );
  }
}