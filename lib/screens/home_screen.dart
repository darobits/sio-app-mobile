import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../widgets/sio_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String getUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    if (user?.email != null && user!.email!.trim().isNotEmpty) {
      return user.email!.split('@').first;
    }

    return 'Operador';
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 46),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disabledCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return _dashboardCard(
      icon: icon,
      title: title,
      color: color,
      onTap: () {},
    );
  }

  Widget _drawerLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1B2B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF16A085).withOpacity(0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A085).withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/logo.jpeg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Sistema Integral\nOperativo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLogo() {
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF16A085).withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A085).withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/logo.jpeg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = getUserName();

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      drawer: Drawer(
        backgroundColor: const Color(0xFF111827),
        child: SafeArea(
          child: Column(
            children: [
              _drawerLogo(),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.inventory_2_rounded),
                title: const Text('Productos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.products);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text('Historial'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Historial próximamente')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRouter.login);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071827),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            _headerLogo(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Hola, $userName!',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.alerts);
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.08,
                  children: [
                    _dashboardCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Recepción',
                      color: const Color(0xFF16A085),
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.reception);
                      },
                    ),
                    _disabledCard(
                      icon: Icons.sync_rounded,
                      title: 'Auditoría',
                      color: const Color(0xFF4F7BFF),
                    ),
                    _dashboardCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Estadísticas',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.statistics);
                      },
                    ),
                    _dashboardCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Alertas',
                      color: const Color(0xFFFF5C70),
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.alerts);
                      },
                    ),
                    _dashboardCard(
                      icon: Icons.folder_rounded,
                      title: 'Productos',
                      color: const Color(0xFFFFC857),
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.products);
                      },
                    ),
                    _disabledCard(
                      icon: Icons.file_download_rounded,
                      title: 'Exportar',
                      color: const Color(0xFFFFA726),
                    ),
                  ],
                ),
              ),
              const SioBottomNav(
                currentRoute: AppRouter.home,
              ),
            ],
          ),
        ),
      ),
    );
  }
}