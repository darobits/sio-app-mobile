import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock_movement.dart';
import '../repositories/stock_history_repository.dart';

final stockHistoryRepositoryProvider = Provider<StockHistoryRepository>((ref) {
  return StockHistoryRepository();
});

final stockHistoryProvider = FutureProvider<List<StockMovement>>((ref) async {
  final repository = ref.read(stockHistoryRepositoryProvider);
  return repository.getMovements();
});