import 'package:flutter/material.dart';

import '../core/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          const SizedBox(height: 16),
          const SizedBox(height: 6),
          const Text(
            'Sistema Integral Operativo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRouter.login);
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
            const Expanded(
              child: Text(
                '¡Hola, Operador!',
                style: TextStyle(
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
            onPressed: () {},
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
                    _disabledCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Estadísticas',
                      color: const Color(0xFF8B5CF6),
                    ),
                    _disabledCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Alertas',
                      color: const Color(0xFFFF5C70),
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
              Container(
                height: 78,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.home_rounded, size: 30),
                    ),
                    GestureDetector(
                      onTap: () => _openScannerOptions(context),
                      child: Container(
                        width: 68,
                        height: 68,
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
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Perfil próximamente')),
                        );
                      },
                      icon: const Icon(Icons.person_outline_rounded, size: 30),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}