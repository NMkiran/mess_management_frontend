import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 2)
class History {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String
      action; // e.g., 'expense_added', 'payment_received', 'attendance_marked'

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String performedBy;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final Map<String, dynamic>? metadata;

  @HiveField(6)
  final String entityType; // e.g., 'expense', 'payment', 'attendance'

  @HiveField(7)
  final String entityId;

  History({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.timestamp,
    this.metadata,
    required this.entityType,
    required this.entityId,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      performedBy: json['performed_by'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'performed_by': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'entity_type': entityType,
      'entity_id': entityId,
    };
  }

  History copyWith({
    String? id,
    String? action,
    String? description,
    String? performedBy,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? entityType,
    String? entityId,
  }) {
    return History(
      id: id ?? this.id,
      action: action ?? this.action,
      description: description ?? this.description,
      performedBy: performedBy ?? this.performedBy,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
    );
  }
}
