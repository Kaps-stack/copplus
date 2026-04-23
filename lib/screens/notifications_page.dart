import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/auth_provider.dart';
import '/providers/notification_provider.dart';
import '/routes/app_routes.dart';
import '/widgets/custom_bottom_nav.dart';
import '/widgets/custom_top_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final auth = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    if (auth.token != null) {
      notificationProvider.fetchNotifications(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // Contenu scrollable
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 110, 0, 130),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer<NotificationProvider>(
                        builder: (context, notifProv, _) {
                          if (notifProv.unreadCount == 0) return const SizedBox.shrink();
                          return TextButton(
                            onPressed: () {
                              final auth = context.read<AuthProvider>();
                              if (auth.token != null) {
                                notifProv.markAllAsRead(auth.token!);
                              }
                            },
                            child: const Text(
                              'Marquer tout comme lu',
                              style: TextStyle(
                                color: Color(0xFFBC7400),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, notifProv, _) {
                    if (notifProv.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: Color(0xFFBC7400),
                          ),
                        ),
                      );
                    }

                    if (notifProv.notifications.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Pas de notifications',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifProv.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifProv.notifications[index];
                        return _buildNotificationTile(
                          context,
                          notification,
                          notifProv,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // TopBar fixée
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () => Navigator.pop(context),
              onNotificationTap: () {},
              onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu),
            ),
          ),

          // BottomNav fixée
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: AppRoutes.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    dynamic notification,
    dynamic notifProv,
  ) {
    final isUnread = !notification.isRead;
    final auth = context.read<AuthProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFBC7400).withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? const Color(0xFFBC7400).withOpacity(0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        onTap: () {
          if (isUnread && auth.token != null) {
            notifProv.markSingleAsRead(auth.token!, notification.id);
          }

          // Redirection selon le type de notification
          if (notification.isServiceRequestCreated) {
            final requestId = notification.data['service_request_id'];
            if (requestId != null) {
              Navigator.pushNamed(
                context,
                AppRoutes.requestDetails,
                arguments: requestId,
              );
            }
          }
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFBC7400).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              notification.isServiceRequestCreated
                  ? Icons.assignment_outlined
                  : Icons.notifications_outlined,
              color: const Color(0xFFBC7400),
              size: 24,
            ),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          notification.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              notification.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFBC7400),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
