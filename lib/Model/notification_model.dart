import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String type; // e.g., "App\Notifications\ServiceRequestCreated"
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['data']?['title'] ?? 'Notification',
      message: json['data']?['message'] ?? '',
      data: json['data'] ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['read_at'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'read_at': isRead ? DateTime.now().toIso8601String() : null,
    };
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    } else if (difference.inHours < 1) {
      return "Il y a ${difference.inMinutes}m";
    } else if (difference.inDays < 1) {
      return "Il y a ${difference.inHours}h";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else {
      return DateFormat('dd/MM/yyyy').format(createdAt);
    }
  }

  bool get isServiceRequestCreated => type.contains('ServiceRequestCreated');
}
