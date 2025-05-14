class MemberModel {
  final String id;
  final String name;
  final String roomNumber;
  final String phoneNumber;
  final String email;
  final bool isActive;
  final DateTime joiningDate;

  MemberModel({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.phoneNumber,
    required this.email,
    this.isActive = true,
    required this.joiningDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roomNumber': roomNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'isActive': isActive,
      'joiningDate': joiningDate.toIso8601String(),
    };
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'],
      name: json['name'],
      roomNumber: json['roomNumber'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      isActive: json['isActive'] ?? true,
      joiningDate: DateTime.parse(json['joiningDate']),
    );
  }
}
