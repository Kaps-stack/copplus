import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/routes/app_routes.dart';
import '/providers/auth_provider.dart';

class CustomBottomNav extends StatelessWidget {
  final String? currentRoute;

  const CustomBottomNav({
    super.key,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) return const SizedBox();

    final String? activeRoute = currentRoute ?? ModalRoute.of(context)?.settings.name;
    final bool isClient = user.role.toLowerCase() == 'client';

    // Détermination de la route "Calendrier" selon le rôle
    // Si client -> AppRoutes.myAppointments, sinon -> AppRoutes.missions
    final String calendarRoute = isClient ? AppRoutes.myAppointments : AppRoutes.missions;

    return Container(
      height: 70,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton(
            context,
            icon: Icons.grid_view_rounded,
            route: AppRoutes.home,
            isActive: activeRoute == AppRoutes.home,
          ),
          
          if (isClient)
            _navButton(
              context,
              icon: Icons.person_search,
              route: AppRoutes.findService,
              isActive: activeRoute == AppRoutes.findService,
            ),

          // Le bouton calendrier dynamique
          _navButton(
            context,
            icon: Icons.calendar_month_rounded,
            route: calendarRoute,
            isActive: activeRoute == calendarRoute,
          ),

          _navButton(
            context,
            icon: Icons.request_page_rounded,
            route: AppRoutes.myRequests,
            isActive: activeRoute == AppRoutes.myRequests,
          ),

          _navButton(
            context,
            icon: Icons.person_rounded,
            route: AppRoutes.profile,
            isActive: activeRoute == AppRoutes.profile,
          ),
          
          _navButton(
            context,
            icon: Icons.menu_open_rounded,
            route: AppRoutes.menu,
            isActive: activeRoute == AppRoutes.menu,
          ),
        ],
      ),
    );
  }

  Widget _navButton(
    BuildContext context, {
    required IconData icon,
    required String route,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFBC7400) : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFBC7400) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}