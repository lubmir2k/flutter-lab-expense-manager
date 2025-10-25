class Expense {
  final String id;
  final double amount;
  final String categoryId;
  final String payee;
  final String note;
  final DateTime date;
  final String tag;

  // Part 1: Default Constructor
  Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.payee,
    required this.note,
    required this.date,
    required this.tag,
  });

  // Part 2: fromJson Factory Constructor
  // Converts a JSON Map into an Expense object.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'],
      categoryId: json['categoryId'],
      payee: json['payee'],
      note: json['note'],
      // Note the parsing required for the DateTime object
      date: DateTime.parse(json['date']),
      tag: json['tag'],
    );
  }

  // Part 3: toJson Method
  // Converts the Expense object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'payee': payee,
      'note': note,
      // DateTime must be converted to a String standard format (ISO 8601) for JSON storage
      'date': date.toIso8601String(),
      'tag': tag,
    };
  }
}