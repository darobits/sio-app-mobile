import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/operational_stats.dart';
import '../repositories/statistics_repository.dart';

enum StatisticsRange {
  today,
  last7Days,
  last30Days,
  currentYear,
}

final statisticsRangeProvider =
    NotifierProvider<StatisticsRangeNotifier, StatisticsRange>(
  StatisticsRangeNotifier.new,
);

class StatisticsRangeNotifier extends Notifier<StatisticsRange> {
  @override
  StatisticsRange build() {
    return StatisticsRange.last30Days;
  }

  void setRange(StatisticsRange range) {
    state = range;
  }
}

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository();
});

final statisticsProvider = FutureProvider<OperationalStats>((ref) async {
  final repository = ref.read(statisticsRepositoryProvider);
  final range = ref.watch(statisticsRangeProvider);

  final now = DateTime.now();

  late DateTime from;
  late DateTime to;

  switch (range) {
    case StatisticsRange.today:
      from = DateTime(now.year, now.month, now.day);
      to = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;

    case StatisticsRange.last7Days:
      from = now.subtract(const Duration(days: 7));
      to = now;
      break;

    case StatisticsRange.last30Days:
      from = now.subtract(const Duration(days: 30));
      to = now;
      break;

    case StatisticsRange.currentYear:
      from = DateTime(now.year, 1, 1);
      to = now;
      break;
  }

  return repository.getStats(
    from: from,
    to: to,
  );
});