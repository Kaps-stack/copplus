import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../providers/notification_provider.dart'; 
import '../providers/auth_provider.dart';

class CustomTopBar extends StatefulWidget implements PreferredSizeWidget {
  final String imagePath;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onMenuTap;

  const CustomTopBar({
    super.key,
    required this.imagePath,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onMenuTap,
  });

  @override
  State<CustomTopBar> createState() => _CustomTopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _CustomTopBarState extends State<CustomTopBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<NotificationProvider>().fetchNotifications(auth.token!);
      }
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Déconnexion", style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écoute réactive du nombre de notifications non lues
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5, bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFB87300),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Image.asset(widget.imagePath, height: 38, errorBuilder: (c, e, s) => const Icon(Icons.handshake, color: Colors.white)),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(text: 'COP', style: TextStyle(color: Color(0xFFE53935))),
                  TextSpan(text: 'PLUS', style: TextStyle(color: Color(0xFFFFEB3B))),
                ],
              ),
            ),
            const Spacer(),
            _buildModernButton(Icons.person_outline_rounded, widget.onProfileTap),
            const SizedBox(width: 8),
            _buildModernButton(
              Icons.notifications_outlined,
              () => Navigator.pushNamed(context, AppRoutes.notifications),
              badgeCount: unreadCount,
            ),
            const SizedBox(width: 8),
            _buildModernButton(Icons.logout_rounded, () => _showLogoutDialog(context), iconColor: const Color(0xFFE53935)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton(IconData icon, VoidCallback onTap, {int badgeCount = 0, Color? iconColor}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: iconColor ?? Colors.black87, size: 22),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -2, top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}