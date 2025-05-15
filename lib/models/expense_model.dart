class ExpenseModel {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final String subCategory;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.subCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'subCategory': subCategory,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
    );
  }
}
