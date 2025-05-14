class AttendanceRecordModel {
  final String id;
  final String memberId;
  final String memberName;
  final DateTime date;
  final bool breakfast;
  final bool lunch;
  final bool dinner;

  AttendanceRecordModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'date': date.toIso8601String(),
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'],
      memberId: json['memberId'],
      memberName: json['memberName'],
      date: DateTime.parse(json['date']),
      breakfast: json['breakfast'],
      lunch: json['lunch'],
      dinner: json['dinner'],
    );
  }
}
