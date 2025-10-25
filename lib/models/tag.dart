class Tag {
  final String id;
  final String name;

  // Part 7: Default Constructor
  Tag({
    required this.id,
    required this.name,
  });

  // Part 8: fromJson Factory Constructor
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
    );
  }

  // Part 9: toJson Method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}