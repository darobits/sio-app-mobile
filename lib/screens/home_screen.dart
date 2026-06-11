import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../providers/user_provider.dart';
import '../widgets/sio_bottom_nav.dart';

// DEMO SEED:
//este import es solo para el método de carga demo, que no forma parte del código real.
import '../services/demo_seed_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Widget _drawerLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          Container(
            width: 172,
            height: 172,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1B2B),
              borderRadius: BorderRadius.circular(95),
              border: Border.all(
                color: const Color(0xFF16A085).withOpacity(0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A085).withOpacity(0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(95),
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
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gestión inteligente de stock',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1B2B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerLogoutButton({
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.11),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.35),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 23,
              ),
              SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarLogo() {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF071827),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF16A085).withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A085).withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(
          'assets/logo.jpeg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _heroCard({
    required String userName,
    required bool isAdmin,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16396E),
            Color(0xFF0B1B2B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, $userName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Panel de control administrativo'
                : 'Panel operativo del empleado',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _miniStatus(
                icon: Icons.verified_user_rounded,
                label: isAdmin ? 'Admin' : 'Operador',
                color: const Color(0xFF16A085),
              ),
              const SizedBox(width: 10),
              _miniStatus(
                icon: Icons.cloud_done_rounded,
                label: 'Online',
                color: const Color(0xFF4F7BFF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatus({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Módulos principales',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'SIO',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO DEMO SEED - BORRAR DESPUÉS:
  // Este método ejecuta la carga demo en Firestore.
  // Cuando confirmes que ya se cargaron products, usuarios, receptions,
  // audits y alerts, borrá este método completo.
  Future<void> _runDemoSeed(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cargando datos demo en Firebase...'),
        ),
      );

      await DemoSeedService.seedDemoData();

      ref.invalidate(currentUserProvider);

      if (!context.mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF16A085),
          content: Text(
            'Datos demo cargados correctamente. Revisá Productos, Stats, Usuarios e Historial.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Error al cargar seed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF071827),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: Color(0xFF071827),
        body: Center(
          child: Text(
            'No se pudo cargar el usuario',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
      data: (appUser) {
        final userName = appUser?.name.trim().isNotEmpty == true
            ? appUser!.name
            : 'Operador';

        final isAdmin = appUser?.isAdmin ?? false;

        final cards = <Widget>[
          _dashboardCard(
            icon: Icons.inventory_2_rounded,
            title: 'Recepción',
            subtitle: 'Alta y carga de mercadería',
            color: const Color(0xFF16A085),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.reception);
            },
          ),
          _dashboardCard(
            icon: Icons.fact_check_rounded,
            title: 'Auditoría',
            subtitle: 'Control real del stock físico',
            color: const Color(0xFF4F7BFF),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.audit);
            },
          ),
          _dashboardCard(
            icon: Icons.warning_amber_rounded,
            title: 'Alertas',
            subtitle: 'Eventos críticos del negocio',
            color: const Color(0xFFFF5C70),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.alerts);
            },
          ),
        ];

        if (isAdmin) {
          cards.addAll([
            _dashboardCard(
              icon: Icons.bar_chart_rounded,
              title: 'Estadísticas',
              subtitle: 'Indicadores y tendencias',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.statistics);
              },
            ),
            _dashboardCard(
              icon: Icons.folder_rounded,
              title: 'Productos',
              subtitle: 'Listado y control de stock',
              color: const Color(0xFFFFC857),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.products);
              },
            ),
            _dashboardCard(
              icon: Icons.file_download_rounded,
              title: 'Exportar',
              subtitle: 'Reportes CSV / Excel / PDF',
              color: const Color(0xFFFFA726),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.exportReports);
              },
            ),
          ]);
        }

        return Scaffold(
          backgroundColor: const Color(0xFF071827),
          drawer: Drawer(
            backgroundColor: const Color(0xFF111827),
            child: SafeArea(
              child: Column(
                children: [
                  _drawerLogo(),
                  const Divider(color: Colors.white12),
                  if (isAdmin)
                    _drawerButton(
                      icon: Icons.inventory_2_rounded,
                      title: 'Productos',
                      color: const Color(0xFFFFC857),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.products);
                      },
                    ),
                  _drawerButton(
                    icon: Icons.fact_check_rounded,
                    title: 'Auditoría',
                    color: const Color(0xFF4F7BFF),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.audit);
                    },
                  ),
                  _drawerButton(
                    icon: Icons.warning_amber_rounded,
                    title: 'Alertas',
                    color: const Color(0xFFFF5C70),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.alerts);
                    },
                  ),
                  if (isAdmin)
                    _drawerButton(
                      icon: Icons.history_rounded,
                      title: 'Historial',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.stockHistory);
                      },
                    ),
                  if (isAdmin)
                    _drawerButton(
                      icon: Icons.manage_accounts_rounded,
                      title: 'Gestión de usuarios',
                      color: const Color(0xFF16A085),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.userManagement);
                      },
                    ),
                  const Spacer(),
                  const Divider(color: Colors.white12),
                  _drawerLogoutButton(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.login,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: const Color(0xFF111827),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            title: Row(
              children: [
                _appBarLogo(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Sistema Integral Operativo',
                    overflow: TextOverflow.ellipsis,
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
              // TODO DEMO SEED - BORRAR DESPUÉS:
              // Botón temporal para cargar datos demo en Firebase.
              // Ejecutalo una sola vez logueado como admin.
              // Después de confirmar que aparecen Productos, Stats,
              // Gestión de usuarios e Historial, borrá este IconButton.
              if (isAdmin)
                IconButton(
                  tooltip: 'Cargar datos demo',
                  onPressed: () {
                    _runDemoSeed(context, ref);
                  },
                  icon: const Icon(
                    Icons.cloud_upload_rounded,
                    color: Color(0xFFFFC857),
                  ),
                ),

              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.alerts);
                },
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 56),
                    children: [
                      _heroCard(
                        userName: userName,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 34),
                      _sectionHeader(),
                      const SizedBox(height: 14),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.96,
                        children: cards,
                      ),
                    ],
                  ),
                ),
              ),
              const SioBottomNav(
                currentRoute: AppRouter.home,
              ),
            ],
          ),
        );
      },
    );
  }
}