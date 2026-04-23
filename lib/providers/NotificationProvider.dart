import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class NotificationProvider with ChangeNotifier {
  int _unreadCount = 0;
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  int get unreadCount => _unreadCount;
  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // Récupérer les notifs depuis Laravel
  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    final url = "${AppConfig.getBaseUrl()}/notifications";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _unreadCount = data['unread_count'];
        _notifications = data['notifications'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Marquer comme lu
  Future<void> markAllAsRead(String token) async {
    final url = "${AppConfig.getBaseUrl()}/notifications/mark-as-read";
    try {
      await http.post(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}