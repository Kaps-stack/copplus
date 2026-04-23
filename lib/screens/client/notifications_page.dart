import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/Model/notification_model.dart';
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
    if (auth.token != null) {
      context.read<NotificationProvider>().fetchNotifications(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 110, 0, 130),
            child: Column(
              children: [
                _buildHeader(),
                Consumer<NotificationProvider>(
                  builder: (context, notifProv, _) {
                    if (notifProv.isLoading) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: Color(0xFFBC7400)),
                      ));
                    }

                    if (notifProv.notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifProv.notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationTile(
                          context,
                          notifProv.notifications[index],
                          notifProv,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              onNotificationTap: () {},
              onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu),
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: AppRoutes.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Consumer<NotificationProvider>(
            builder: (context, notifProv, _) {
              if (notifProv.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  final token = context.read<AuthProvider>().token;
                  if (token != null) notifProv.markAllAsRead(token);
                },
                child: const Text('Tout marquer lu', style: TextStyle(color: Color(0xFFBC7400))),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationModel notification, NotificationProvider notifProv) {
    final auth = context.read<AuthProvider>();
    final bool isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFBC7400).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isUnread ? const Color(0xFFBC7400).withOpacity(0.2) : Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () async {
          // 1. Marquer comme lu
          if (isUnread && auth.token != null) {
            await notifProv.markSingleAsRead(auth.token!, notification.id);
          }

          // 2. Redirection spécifique
          if (notification.isServiceRequestCreated) {
            final requestId = notification.data['service_request_id'];
            if (requestId != null) {
              Navigator.pushNamed(
                context, 
                AppRoutes.myRequestDetails, // Utilise ta route de détails
                arguments: requestId
              );
            }
          }
        },
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFBC7400).withOpacity(0.1),
          child: Icon(
            notification.isServiceRequestCreated ? Icons. assignment_turned_in_rounded : Icons.notifications,
            color: const Color(0xFFBC7400),
          ),
        ),
        title: Text(notification.title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(notification.formattedDate, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
          const Text("Aucune notification", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}