class PaymentModel {
  final String id;
  final String name;
  final String type;
  final double amount;
  final String description;
  final String category;
  final String subCategory;
  final String paymentMethod;
  final String upiSubType;
  final String imageUrl;
  final DateTime date;

  PaymentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.paymentMethod,
    required this.upiSubType,
    required this.imageUrl,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'amount': amount,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'paymentMethod': paymentMethod,
      'upiSubType': upiSubType,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',

      amount: (json['amount'] ?? 0).toDouble(),

      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      upiSubType: json['upiSubType'] ?? '',
      imageUrl: json['imageUrl'] ?? '',

      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),

    );
  }
}
