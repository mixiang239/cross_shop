import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/mock_data_service.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _items = [];

  List<NotificationItem> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;

  NotificationProvider() {
    _items.addAll(MockDataService.notifications);
  }

  void markAsRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _items[idx] = _readCopy(idx);
      notifyListeners();
    }
  }

  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].read) {
        _items[i] = _readCopy(i);
      }
    }
    notifyListeners();
  }

  NotificationItem _readCopy(int i) {
    final n = _items[i];
    return NotificationItem(
      id: n.id, title: n.title, body: n.body,
      type: n.type, createdAt: n.createdAt, read: true,
      actionRoute: n.actionRoute,
    );
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}
