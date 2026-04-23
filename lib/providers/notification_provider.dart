import 'package:flutter/material.dart';

import '/Model/notification_model.dart';
import '/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _notificationService.fetchNotifications(token);
      _notifications = result['notifications'] as List<NotificationModel>;
      _unreadCount = result['unread_count'] as int;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _unreadCount = 0;
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String token) async {
    try {
      await _notificationService.markAsRead(token);
      for (var notification in _notifications) {
        notification.isRead = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markSingleAsRead(String token, String notificationId) async {
    try {
      await _notificationService.markSingleAsRead(token, notificationId);
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => NotificationModel(
          id: '',
          type: '',
          title: '',
          message: '',
          data: {},
          createdAt: DateTime.now(),
        ),
      );
      if (notification.id.isNotEmpty && !notification.isRead) {
        notification.isRead = true;
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}
