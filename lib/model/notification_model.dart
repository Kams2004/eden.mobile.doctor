class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String? updatedAt;
  final int userId;
  final int types;
  final bool allUsers;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.updatedAt,
    required this.userId,
    required this.types,
    required this.allUsers,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
      userId: json['user_id'] ?? 0,
      types: json['types'] ?? 0,
      allUsers: json['all_users'] ?? false,
    );
  }
}

class NotificationType {
  final int id;
  final String name;
  final String? description;

  NotificationType({
    required this.id,
    required this.name,
    this.description,
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) {
    return NotificationType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}