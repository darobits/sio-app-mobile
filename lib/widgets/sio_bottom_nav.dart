import 'package:flutter/material.dart';

import '../core/router/app_router.dart';

class SioBottomNav extends StatelessWidget {
  final String currentRoute;

  const SioBottomNav({
    super.key,
    required this.currentRoute,
  });

  void _goTo(BuildContext context, String route) {
    if (currentRoute == route) return;

    Navigator.pushReplacementNamed(context, route);
  }

  void _openScannerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                '¿Qué querés escanear?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _scannerOption(
                context: context,
                icon: Icons.inventory_2_rounded,
                title: 'Recepción de mercadería',
                subtitle: 'Dar de alta o sumar stock recibido',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.reception);
                },
              ),
              const SizedBox(height: 12),
              _scannerOption(
                context: context,
                icon: Icons.fact_check_rounded,
                title: 'Auditoría de stock',
                subtitle: 'Controlar stock esperado vs stock real',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Auditoría estará disponible pronto'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _scannerOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1B2B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF16A085), size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return GestureDetector(
      onTap: () => _goTo(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF16A085) : Colors.white54,
            size: 27,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF16A085) : Colors.white54,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(
            context: context,
            icon: Icons.home_rounded,
            label: 'Inicio',
            route: AppRouter.home,
          ),
          _navItem(
            context: context,
            icon: Icons.bar_chart_rounded,
            label: 'Stats',
            route: AppRouter.statistics,
          ),
          GestureDetector(
            onTap: () => _openScannerOptions(context),
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
          _navItem(
            context: context,
            icon: Icons.notifications_none_rounded,
            label: 'Alertas',
            route: AppRouter.alerts,
          ),
          _navItem(
            context: context,
            icon: Icons.person_outline_rounded,
            label: 'Perfil',
            route: AppRouter.profile,
          ),
        ],
      ),
    );
  }
}