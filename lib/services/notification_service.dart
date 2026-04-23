import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/notification_model.dart';
import '../config/app_config.dart';

class NotificationService {
  final String baseUrl = AppConfig.getBaseUrl();

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>> fetchNotifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<NotificationModel> notifications =
            (data['notifications'] as List)
                .map((n) => NotificationModel.fromJson(n))
                .toList();
        final int unreadCount = data['unread_count'] ?? 0;

        return {'notifications': notifications, 'unread_count': unreadCount};
      } else {
        throw Exception('Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> markAsRead(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/mark-as-read'),
        headers: _headers(token),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour des notifications');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> markSingleAsRead(String token, String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: _headers(token),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour de la notification');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
