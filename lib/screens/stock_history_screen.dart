import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../models/stock_movement.dart';
import '../providers/stock_history_provider.dart';
import '../widgets/sio_bottom_nav.dart';

class StockHistoryScreen extends ConsumerStatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  ConsumerState<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends ConsumerState<StockHistoryScreen> {
  String selectedFilter = 'all';

  List<StockMovement> _filterMovements(List<StockMovement> movements) {
    if (selectedFilter == 'all') return movements;

    return movements.where((movement) {
      return movement.type == selectedFilter;
    }).toList();
  }

  Color _movementColor(String type) {
    switch (type) {
      case 'reception':
        return const Color(0xFF16A085);
      case 'audit':
        return const Color(0xFF4F7BFF);
      case 'alert':
        return const Color(0xFFFF5C70);
      default:
        return Colors.white54;
    }
  }

  IconData _movementIcon(String type) {
    switch (type) {
      case 'reception':
        return Icons.local_shipping_rounded;
      case 'audit':
        return Icons.fact_check_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  Widget _header(List<StockMovement> movements) {
    final receptions =
        movements.where((movement) => movement.type == 'reception').length;
    final audits = movements.where((movement) => movement.type == 'audit').length;
    final alerts =
        movements.where((movement) => movement.type == 'alert').length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF16396E),
            Color(0xFF071827),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.history_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 16),
          const Text(
            'Historial operativo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Trazabilidad de recepciones, auditorías y alertas generadas por el sistema.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _summaryBadge(
                label: 'Recepciones',
                value: receptions.toString(),
                color: const Color(0xFF16A085),
              ),
              const SizedBox(width: 8),
              _summaryBadge(
                label: 'Auditorías',
                value: audits.toString(),
                color: const Color(0xFF4F7BFF),
              ),
              const SizedBox(width: 8),
              _summaryBadge(
                label: 'Alertas',
                value: alerts.toString(),
                color: const Color(0xFFFF5C70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterButton('all', 'Todos', const Color(0xFF16A085)),
          _filterButton('reception', 'Recepciones', const Color(0xFF16A085)),
          _filterButton('audit', 'Auditorías', const Color(0xFF4F7BFF)),
          _filterButton('alert', 'Alertas', const Color(0xFFFF5C70)),
        ],
      ),
    );
  }

  Widget _filterButton(String value, String label, Color color) {
    final isSelected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() => selectedFilter = value);
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.18) : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.55) : Colors.white10,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _movementCard(StockMovement movement) {
    final color = _movementColor(movement.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _movementIcon(movement.type),
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  movement.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                  ),
                ),
                if (movement.barcode.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Código: ${movement.barcode}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                _movementDetails(movement),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 15,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        movement.userEmail,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(movement.createdAt),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _movementDetails(StockMovement movement) {
    if (movement.type == 'reception') {
      return _detailsBox(
        color: const Color(0xFF16A085),
        text:
            'Ingreso: ${movement.quantity ?? 0} u. | Stock: ${movement.previousStock ?? "-"} → ${movement.newStock ?? "-"}',
      );
    }

    if (movement.type == 'audit') {
      return _detailsBox(
        color: const Color(0xFF4F7BFF),
        text:
            'Esperado: ${movement.expectedStock ?? "-"} | Real: ${movement.realStock ?? "-"} | Dif: ${movement.difference ?? "-"}',
      );
    }

    return _detailsBox(
      color: const Color(0xFFFF5C70),
      text: movement.difference == null
          ? 'Evento generado automáticamente'
          : 'Diferencia detectada: ${movement.difference}',
    );
  }

  Widget _detailsBox({
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: Colors.white38,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'No hay movimientos para mostrar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando registres recepciones, auditorías o alertas, aparecerán en este historial.',
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

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(stockHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Historial'),
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.home,
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => const Center(
          child: Text(
            'No se pudo cargar el historial',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        data: (movements) {
          final filtered = _filterMovements(movements);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(stockHistoryProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _header(movements),
                const SizedBox(height: 18),
                _filters(),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  _emptyState()
                else
                  ...filtered.map(_movementCard),
              ],
            ),
          );
        },
      ),
    );
  }
}