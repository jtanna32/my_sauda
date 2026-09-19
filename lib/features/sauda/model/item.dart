class Item {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['user_id'],
      name: json['item_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Item copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
