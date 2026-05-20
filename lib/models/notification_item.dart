enum NotificationType { order, promotion, system }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;
  final String? actionRoute;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
    this.actionRoute,
  });
}
