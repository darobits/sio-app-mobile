import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reception.dart';
import '../repositories/reception_repository.dart';

final receptionRepositoryProvider = Provider<ReceptionRepository>((ref) {
  return ReceptionRepository();
});

final receptionProvider =
    AsyncNotifierProvider<ReceptionNotifier, List<Reception>>(
  ReceptionNotifier.new,
);

class ReceptionNotifier extends AsyncNotifier<List<Reception>> {
  late final ReceptionRepository _repository;

  @override
  Future<List<Reception>> build() async {
    _repository = ref.read(receptionRepositoryProvider);
    return _repository.getReceptions();
  }

  Future<void> loadReceptions() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _repository.getReceptions();
    });
  }
}