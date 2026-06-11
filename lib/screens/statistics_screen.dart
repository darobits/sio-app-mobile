import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../models/operational_stats.dart';
import '../providers/statistics_provider.dart';
import '../widgets/sio_bottom_nav.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  static const int _tablePageSize = 10;

  int _usersPage = 0;
  int _productsPage = 0;
  int _differencesPage = 0;

  Color _chartColor(int index) {
    final colors = [
      const Color(0xFF16A085),
      const Color(0xFF4F7BFF),
      const Color(0xFFFFC857),
      const Color(0xFFFF5C70),
      const Color(0xFF8B5CF6),
      const Color(0xFFFFA726),
    ];

    return colors[index % colors.length];
  }

  void _resetTablePages() {
    _usersPage = 0;
    _productsPage = 0;
    _differencesPage = 0;
  }

  Widget _rangeButton({
    required StatisticsRange current,
    required StatisticsRange value,
    required String label,
  }) {
    final selected = current == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _resetTablePages();
        });

        ref.read(statisticsRangeProvider.notifier).setRange(value);
        ref.invalidate(statisticsProvider);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF16A085) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF16A085) : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white60,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _kpiGrid(OperationalStats stats) {
    final items = [
      _KpiItem(
        Icons.inventory_2_rounded,
        'Productos',
        '${stats.totalProducts}',
        const Color(0xFF16A085),
      ),
      _KpiItem(
        Icons.warehouse_rounded,
        'Stock actual',
        '${stats.totalStock}',
        const Color(0xFF22C55E),
      ),
      _KpiItem(
        Icons.local_shipping_rounded,
        'Recepciones',
        '${stats.totalReceptions}',
        const Color(0xFF4F7BFF),
      ),
      _KpiItem(
        Icons.add_box_rounded,
        'Unidades recibidas',
        '${stats.totalReceivedUnits}',
        const Color(0xFFFFC857),
      ),
      _KpiItem(
        Icons.fact_check_rounded,
        'Auditorías',
        '${stats.totalAudits}',
        const Color(0xFF8B5CF6),
      ),
      _KpiItem(
        Icons.warning_amber_rounded,
        'Con diferencia',
        '${stats.auditsWithDifference}',
        const Color(0xFFFF5C70),
      ),
      _KpiItem(
        Icons.production_quantity_limits_rounded,
        'Stock bajo',
        '${stats.lowStockProducts}',
        const Color(0xFFFFA726),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: item.color.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: item.color, size: 30),
              const Spacer(),
              Text(
                item.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _chartContainer({
    required int itemCount,
    required Widget Function(double chartWidth) builder,
  }) {
    return Container(
      height: 285,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final calculatedWidth = itemCount <= 1
              ? constraints.maxWidth
              : itemCount * 40.0;

          final chartWidth = math.max(
            constraints.maxWidth,
            calculatedWidth,
          );

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              child: builder(chartWidth),
            ),
          );
        },
      ),
    );
  }

  int _dateLabelInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 15) return 2;
    if (count <= 31) return 4;
    if (count <= 70) return 7;
    if (count <= 130) return 14;
    if (count <= 220) return 21;
    return 30;
  }

  bool _shouldShowDateLabel({
    required int index,
    required int total,
  }) {
    if (index == 0 || index == total - 1) {
      return true;
    }

    final interval = _dateLabelInterval(total);
    return index % interval == 0;
  }

  String _shortDateLabel(String value) {
    final clean = value.trim();

    if (clean.contains('-')) {
      final parts = clean.split('-');

      if (parts.length >= 3) {
        final month = parts[1].padLeft(2, '0');
        final day = parts[2].padLeft(2, '0');

        return '$day/$month';
      }
    }

    if (clean.contains('/')) {
      final parts = clean.split('/');

      if (parts.length >= 2) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');

        return '$day/$month';
      }
    }

    if (clean.length > 8) {
      return clean.substring(0, 8);
    }

    return clean;
  }

  Widget _bottomDateTitle({
    required double value,
    required List<MapEntry<String, int>> entries,
  }) {
    final index = value.toInt();

    if (index < 0 || index >= entries.length) {
      return const SizedBox.shrink();
    }

    if (!_shouldShowDateLabel(index: index, total: entries.length)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Transform.rotate(
        angle: -0.65,
        child: Text(
          _shortDateLabel(entries[index].key),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _barChart(OperationalStats stats) {
    final entries = stats.receptionsByDay.entries.toList();

    if (entries.isEmpty) {
      return _emptyBox('No hay datos suficientes para graficar actividad.');
    }

    final maxValue = entries
        .map((entry) => entry.value)
        .fold<int>(0, (max, value) => value > max ? value : max);

    return _chartContainer(
      itemCount: entries.length,
      builder: (_) {
        return BarChart(
          BarChartData(
            maxY: maxValue <= 0 ? 1 : maxValue.toDouble() + 1,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withOpacity(0.07),
                strokeWidth: 1,
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(10),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final entry = entries[group.x.toInt()];

                  return BarTooltipItem(
                    '${entry.key}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${entry.value} recepciones',
                        style: const TextStyle(
                          color: Color(0xFF16A085),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 58,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return _bottomDateTitle(
                      value: value,
                      entries: entries,
                    );
                  },
                ),
              ),
            ),
            groupsSpace: 8,
            barGroups: List.generate(entries.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entries[index].value.toDouble(),
                    width: 16,
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFF16A085),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _lineChart(OperationalStats stats) {
    final entries = stats.receptionsByDay.entries.toList();

    if (entries.isEmpty) {
      return _emptyBox('No hay datos suficientes para graficar evolución.');
    }

    final maxValue = entries
        .map((entry) => entry.value)
        .fold<int>(0, (max, value) => value > max ? value : max);

    final showDots = entries.length <= 35;

    return _chartContainer(
      itemCount: entries.length,
      builder: (_) {
        return LineChart(
          LineChartData(
            minX: 0,
            maxX: entries.length <= 1 ? 1 : (entries.length - 1).toDouble(),
            minY: 0,
            maxY: maxValue <= 0 ? 1 : maxValue.toDouble() + 1,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withOpacity(0.08),
                strokeWidth: 1,
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(10),
                tooltipMargin: 8,
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    final index = spot.x.toInt();

                    if (index < 0 || index >= entries.length) {
                      return null;
                    }

                    final entry = entries[index];

                    return LineTooltipItem(
                      '${entry.key}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: '${entry.value} recepciones',
                          style: const TextStyle(
                            color: Color(0xFF4F7BFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 58,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return _bottomDateTitle(
                      value: value,
                      entries: entries,
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(entries.length, (index) {
                  return FlSpot(
                    index.toDouble(),
                    entries[index].value.toDouble(),
                  );
                }),
                isCurved: true,
                barWidth: 4,
                color: const Color(0xFF4F7BFF),
                dotData: FlDotData(show: showDots),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF4F7BFF).withOpacity(0.16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pieChart({
    required Map<String, int> data,
    required String emptyMessage,
  }) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return _emptyBox(emptyMessage);
    }

    final visibleEntries = entries.take(6).toList();
    final total = visibleEntries.fold<int>(0, (sum, item) => sum + item.value);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 48,
                sectionsSpace: 3,
                sections: List.generate(visibleEntries.length, (index) {
                  final entry = visibleEntries[index];
                  final percent = total == 0 ? 0 : (entry.value / total) * 100;

                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: _chartColor(index),
                    radius: 72,
                    title: '${percent.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(visibleEntries.length, (index) {
              final entry = visibleEntries[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _chartColor(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _dataTable({
    required List<String> headers,
    required List<List<String>> rows,
    required String emptyMessage,
    required int currentPage,
    required ValueChanged<int> onPageChanged,
  }) {
    if (rows.isEmpty) {
      return _emptyBox(emptyMessage);
    }

    final totalPages = (rows.length / _tablePageSize).ceil();
    final safePage = currentPage.clamp(0, totalPages - 1);
    final start = safePage * _tablePageSize;
    final end = math.min(start + _tablePageSize, rows.length);
    final visibleRows = rows.sublist(start, end);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  headers[0],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 112,
                child: Text(
                  headers[1],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(visibleRows.length, (index) {
            final row = visibleRows[index];
            final realIndex = start + index + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A085).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$realIndex',
                      style: const TextStyle(
                        color: Color(0xFF16A085),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row[0],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A085).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          row[1],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF16A085),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          _paginationControls(
            currentPage: safePage,
            totalPages: totalPages,
            start: start,
            end: end,
            totalRows: rows.length,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }

  Widget _paginationControls({
    required int currentPage,
    required int totalPages,
    required int start,
    required int end,
    required int totalRows,
    required ValueChanged<int> onPageChanged,
  }) {
    final canGoBack = currentPage > 0;
    final canGoNext = currentPage < totalPages - 1;

    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mostrando ${start + 1}-$end de $totalRows',
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
                    onPageChanged(currentPage - 1);
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
              '${currentPage + 1}/$totalPages',
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
                    onPageChanged(currentPage + 1);
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

  Widget _rankingTable({
    required String emptyMessage,
    required Map<String, int> data,
    required IconData icon,
    required Color color,
  }) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return _emptyBox(emptyMessage);
    }

    return Column(
      children: entries.take(6).map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.key,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${entry.value}',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white60),
      ),
    );
  }

  List<List<String>> _buildUserRows(OperationalStats stats) {
    final entries = stats.receptionsByUser.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) => [entry.key, '${entry.value}']).toList();
  }

  List<List<String>> _buildProductRows(OperationalStats stats) {
    final entries = stats.receivedUnitsByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) => [entry.key, '${entry.value}']).toList();
  }

  List<List<String>> _buildDifferenceRows(OperationalStats stats) {
    final entries = stats.auditsDifferenceByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) => [entry.key, '${entry.value}']).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsProvider);
    final currentRange = ref.watch(statisticsRangeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Estadísticas'),
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.statistics,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text(
            'No se pudieron cargar las estadísticas',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        data: (stats) {
          final userRows = _buildUserRows(stats);
          final productRows = _buildProductRows(stats);
          final differenceRows = _buildDifferenceRows(stats);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _resetTablePages();
              });

              ref.invalidate(statisticsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF16396E),
                        Color(0xFF071827),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel de inteligencia operativa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Indicadores de stock, recepción, auditoría, usuarios y movimientos críticos.',
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _rangeButton(
                        current: currentRange,
                        value: StatisticsRange.today,
                        label: 'Hoy',
                      ),
                      const SizedBox(width: 8),
                      _rangeButton(
                        current: currentRange,
                        value: StatisticsRange.last7Days,
                        label: '7 días',
                      ),
                      const SizedBox(width: 8),
                      _rangeButton(
                        current: currentRange,
                        value: StatisticsRange.last30Days,
                        label: '30 días',
                      ),
                      const SizedBox(width: 8),
                      _rangeButton(
                        current: currentRange,
                        value: StatisticsRange.currentYear,
                        label: 'Año',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _kpiGrid(stats),
                const SizedBox(height: 28),
                _sectionTitle(
                  'Actividad diaria',
                  'Recepciones registradas por día en el período seleccionado. Deslizá el gráfico hacia los costados para ver más fechas.',
                ),
                const SizedBox(height: 12),
                _barChart(stats),
                const SizedBox(height: 28),
                _sectionTitle(
                  'Evolución de recepciones',
                  'Tendencia de carga operativa a lo largo del período. Deslizá horizontalmente si hay muchas fechas.',
                ),
                const SizedBox(height: 12),
                _lineChart(stats),
                const SizedBox(height: 28),
                _sectionTitle(
                  'Distribución por productos',
                  'Participación de productos según unidades recibidas.',
                ),
                const SizedBox(height: 12),
                _pieChart(
                  data: stats.receivedUnitsByProduct,
                  emptyMessage: 'No hay datos de productos para graficar.',
                ),
                const SizedBox(height: 28),
                _sectionTitle(
                  'Distribución por usuario',
                  'Participación de operadores según cantidad de recepciones.',
                ),
                const SizedBox(height: 12),
                _pieChart(
                  data: stats.receptionsByUser,
                  emptyMessage: 'No hay datos de usuarios para graficar.',
                ),
                const SizedBox(height: 28),
                _sectionTitle(
                  'Ranking de operadores',
                  'Cantidad de recepciones realizadas por usuario.',
                ),
                const SizedBox(height: 12),
                _rankingTable(
                  emptyMessage: 'Todavía no hay recepciones por usuario.',
                  data: stats.receptionsByUser,
                  icon: Icons.person_rounded,
                  color: const Color(0xFF16A085),
                ),
                const SizedBox(height: 18),
                _dataTable(
                  headers: const ['Usuario', 'Recepciones'],
                  rows: userRows,
                  emptyMessage: 'Sin datos de usuarios.',
                  currentPage: _usersPage,
                  onPageChanged: (page) {
                    setState(() {
                      _usersPage = page;
                    });
                  },
                ),
                const SizedBox(height: 28),
                _sectionTitle(
                  'Productos más recibidos',
                  'Ranking de productos con mayor ingreso de unidades.',
                ),
                const SizedBox(height: 12),
                _rankingTable(
                  emptyMessage: 'Todavía no hay productos recibidos.',
                  data: stats.receivedUnitsByProduct,
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFFFFC857),
                ),
                const SizedBox(height: 18),
                _dataTable(
                  headers: const ['Producto', 'Unidades'],
                  rows: productRows,
                  emptyMessage: 'Sin datos de productos.',
                  currentPage: _productsPage,
                  onPageChanged: (page) {
                    setState(() {
                      _productsPage = page;
                    });
                  },
                ),
                const SizedBox(height: 28),
                _sectionTitle(
                  'Diferencias detectadas',
                  'Productos con diferencias encontradas durante auditorías.',
                ),
                const SizedBox(height: 12),
                _rankingTable(
                  emptyMessage: 'No se detectaron diferencias de stock.',
                  data: stats.auditsDifferenceByProduct,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFFF5C70),
                ),
                const SizedBox(height: 18),
                _dataTable(
                  headers: const ['Producto', 'Dif.'],
                  rows: differenceRows,
                  emptyMessage: 'Sin diferencias registradas.',
                  currentPage: _differencesPage,
                  onPageChanged: (page) {
                    setState(() {
                      _differencesPage = page;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KpiItem {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  _KpiItem(
    this.icon,
    this.title,
    this.value,
    this.color,
  );
}