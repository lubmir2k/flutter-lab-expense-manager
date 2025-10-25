class Category {
  final String id;
  final String name;

  // Part 4: Default Constructor
  Category({
    required this.id,
    required this.name,
  });

  // Part 5: fromJson Factory Constructor
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }

  // Part 6: toJson Method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}