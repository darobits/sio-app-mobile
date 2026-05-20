import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sio_alert.dart';
import '../repositories/alert_repository.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository();
});

final alertsProvider = FutureProvider<List<SioAlert>>((ref) async {
  final repository = ref.read(alertRepositoryProvider);
  return repository.getAlerts();
});

class AlertSettings {
  final bool stockLow;
  final bool auditDifferences;
  final bool inactiveProducts;
  final bool abnormalLoads;

  AlertSettings({
    required this.stockLow,
    required this.auditDifferences,
    required this.inactiveProducts,
    required this.abnormalLoads,
  });

  AlertSettings copyWith({
    bool? stockLow,
    bool? auditDifferences,
    bool? inactiveProducts,
    bool? abnormalLoads,
  }) {
    return AlertSettings(
      stockLow: stockLow ?? this.stockLow,
      auditDifferences: auditDifferences ?? this.auditDifferences,
      inactiveProducts: inactiveProducts ?? this.inactiveProducts,
      abnormalLoads: abnormalLoads ?? this.abnormalLoads,
    );
  }
}

class AlertSettingsNotifier extends Notifier<AlertSettings> {
  @override
  AlertSettings build() {
    return AlertSettings(
      stockLow: true,
      auditDifferences: true,
      inactiveProducts: false,
      abnormalLoads: false,
    );
  }

  void toggleStockLow(bool value) {
    state = state.copyWith(stockLow: value);
  }

  void toggleAuditDifferences(bool value) {
    state = state.copyWith(auditDifferences: value);
  }

  void toggleInactiveProducts(bool value) {
    state = state.copyWith(inactiveProducts: value);
  }

  void toggleAbnormalLoads(bool value) {
    state = state.copyWith(abnormalLoads: value);
  }
}

final alertSettingsProvider =
    NotifierProvider<AlertSettingsNotifier, AlertSettings>(
  AlertSettingsNotifier.new,
);