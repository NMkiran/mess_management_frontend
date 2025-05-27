import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String subCategory;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.subCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      subCategory: json['subCategory'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
      'subCategory': subCategory,
    };
  }

  Expense copyWith({
    String? id,
    String? category,
    String? description,
    double? amount,
    String? subCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      subCategory: subCategory ?? this.subCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
