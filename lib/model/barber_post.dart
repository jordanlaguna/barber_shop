class BarberPost {
  final String id;
  final String name;
  final String type;
  final String image;
  final String barberName;
  final String avatar;
  final DateTime createdAt;
  final int likes;

  BarberPost({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.barberName,
    required this.avatar,
    required this.createdAt,
    required this.likes,
  });

  factory BarberPost.fromMap(String id, Map<String, dynamic> map) {
    return BarberPost(
      id: id,
      name: map['name'],
      type: map['type'],
      image: map['image'],
      barberName: map['barberName'],
      avatar: map['avatar'],
      createdAt: map['createdAt'].toDate(),
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "type": type,
      "image": image,
      "barberName": barberName,
      "avatar": avatar,
      "createdAt": createdAt,
      "likes": likes,
    };
  }
}
