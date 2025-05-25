class MemberModel {
  final String id;
  final String name;
  final String roomNumber;
  final String phoneNumber;
  final String email;
  final String pic;
  final String aadharCard;
  final String address;
  final bool isActive;
  final DateTime createdAt;

  MemberModel({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.phoneNumber,
    required this.email,
    this.pic = "",
    this.aadharCard = "",
    this.address = "",
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roomNumber': roomNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'pic': pic,
      'aadharCard': aadharCard,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'], // Note: API returns _id instead of id
      name: json['name'],
      roomNumber: json['roomNumber'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      pic: json['pic'] ?? "",
      aadharCard: json['aadharCard'] ?? "",
      address: json['address'] ?? "",
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
