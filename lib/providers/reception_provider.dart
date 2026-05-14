import 'package:flutter/material.dart';

import '../models/reception.dart';
import '../repositories/reception_repository.dart';

class ReceptionProvider extends ChangeNotifier {
  final ReceptionRepository _repository = ReceptionRepository();

  List<Reception> receptions = [];
  bool loading = false;
  String? error;

  Future<void> loadReceptions() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      receptions = await _repository.getReceptions();
    } catch (e) {
      error = 'No se pudo cargar el historial de recepciones';
    }

    loading = false;
    notifyListeners();
  }
}