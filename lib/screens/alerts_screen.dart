import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../models/sio_alert.dart';
import '../providers/alert_provider.dart';
import '../services/notification_service.dart';
import '../widgets/sio_bottom_nav.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  static const int _alertsPageSize = 10;

  int _currentPage = 0;

  Color _alertColor(String type) {
    switch (type) {
      case 'stock_difference':
        return const Color(0xFFFF5C70);
      case 'low_stock':
        return const Color(0xFFFFA726);
      case 'inactive_product':
        return const Color(0xFF8B5CF6);
      case 'abnormal_load':
        return const Color(0xFF4F7BFF);
      default:
        return const Color(0xFF16A085);
    }
  }

  IconData _alertIcon(String type) {
    switch (type) {
      case 'stock_difference':
        return Icons.warning_amber_rounded;
      case 'low_stock':
        return Icons.production_quantity_limits_rounded;
      case 'inactive_product':
        return Icons.schedule_rounded;
      case 'abnormal_load':
        return Icons.trending_up_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }

  Widget _settingsCard(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(alertSettingsProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración de alertas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elegí qué eventos importantes deben avisarte en el celular.',
            style: TextStyle(
              color: Colors.white54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          _switchTile(
            title: 'Stock bajo',
            subtitle: 'Avisar cuando un producto esté por agotarse',
            value: settings.stockLow,
            color: const Color(0xFFFFA726),
            onChanged: ref.read(alertSettingsProvider.notifier).toggleStockLow,
          ),
          _switchTile(
            title: 'Diferencias de auditoría',
            subtitle: 'Avisar cuando el stock real no coincida',
            value: settings.auditDifferences,
            color: const Color(0xFFFF5C70),
            onChanged:
                ref.read(alertSettingsProvider.notifier).toggleAuditDifferences,
          ),
          _switchTile(
            title: 'Productos sin movimiento',
            subtitle: 'Detectar productos quietos por mucho tiempo',
            value: settings.inactiveProducts,
            color: const Color(0xFF8B5CF6),
            onChanged:
                ref.read(alertSettingsProvider.notifier).toggleInactiveProducts,
          ),
          _switchTile(
            title: 'Cargas anormales',
            subtitle: 'Avisar cargas muy altas o poco habituales',
            value: settings.abnormalLoads,
            color: const Color(0xFF4F7BFF),
            onChanged:
                ref.read(alertSettingsProvider.notifier).toggleAbnormalLoads,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await NotificationService.showNotification(
                  title: 'Alerta SIO',
                  body: 'Notificación de prueba activada correctamente.',
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificación de prueba enviada'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Probar notificación'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF16A085),
                side: const BorderSide(color: Color(0xFF16A085)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _alertCard({
    required BuildContext context,
    required WidgetRef ref,
    required SioAlert alert,
  }) {
    final color = _alertColor(alert.type);

    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.redAccent,
        ),
      ),
      onDismissed: (_) async {
        final repository = ref.read(alertRepositoryProvider);
        await repository.deleteAlert(alert.id);

        setState(() {
          _currentPage = 0;
        });

        ref.invalidate(alertsProvider);
      },
      child: InkWell(
        onTap: () async {
          if (!alert.read) {
            final repository = ref.read(alertRepositoryProvider);
            await repository.markAsRead(alert.id);
            ref.invalidate(alertsProvider);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: alert.read
                ? const Color(0xFF111827)
                : color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: alert.read ? Colors.white10 : color.withOpacity(0.45),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _alertIcon(alert.type),
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      alert.message,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          _formatDate(alert.createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (!alert.read)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Nueva',
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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

  Widget _emptyAlerts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: Colors.white38,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'No hay alertas por ahora',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando SIO detecte diferencias, stock bajo o eventos importantes, aparecerán acá.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paginationControls({
    required int totalAlerts,
    required int totalPages,
    required int start,
    required int end,
  }) {
    final canGoBack = _currentPage > 0;
    final canGoNext = _currentPage < totalPages - 1;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mostrando ${start + 1}-$end de $totalAlerts',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Anterior',
            onPressed: canGoBack
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: canGoBack ? Colors.white : Colors.white24,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              '${_currentPage + 1}/$totalPages',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Siguiente',
            onPressed: canGoNext
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: canGoNext ? Colors.white : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertsList({
    required BuildContext context,
    required WidgetRef ref,
    required List<SioAlert> alerts,
  }) {
    if (alerts.isEmpty) {
      return _emptyAlerts();
    }

    final totalPages = (alerts.length / _alertsPageSize).ceil();

    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }

    final start = _currentPage * _alertsPageSize;
    final end = math.min(start + _alertsPageSize, alerts.length);
    final visibleAlerts = alerts.sublist(start, end);

    return Column(
      children: [
        ...visibleAlerts.map((alert) {
          return _alertCard(
            context: context,
            ref: ref,
            alert: alert,
          );
        }),
        if (alerts.length > _alertsPageSize)
          _paginationControls(
            totalAlerts: alerts.length,
            totalPages: totalPages,
            start: start,
            end: end,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Alertas'),
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.alerts,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _currentPage = 0;
          });

          ref.invalidate(alertsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF5C70),
                    Color(0xFF111827),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Centro de alertas inteligentes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Seguimiento de eventos críticos para anticipar problemas operativos.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _settingsCard(context, ref),
            const SizedBox(height: 26),
            const Text(
              'Alertas recientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            alertsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => const Text(
                'No se pudieron cargar las alertas',
                style: TextStyle(color: Colors.white70),
              ),
              data: (alerts) {
                return _alertsList(
                  context: context,
                  ref: ref,
                  alerts: alerts,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}