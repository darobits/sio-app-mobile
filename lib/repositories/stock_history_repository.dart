import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stock_movement.dart';

class StockHistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<StockMovement>> getMovements() async {
    final receptionsSnapshot = await _db
        .collection('receptions')
        .orderBy('createdAt', descending: true)
        .get();

    final auditsSnapshot = await _db
        .collection('audits')
        .orderBy('createdAt', descending: true)
        .get();

    final alertsSnapshot = await _db
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .get();

    final movements = <StockMovement>[
      ...receptionsSnapshot.docs.map(_mapReception),
      ...auditsSnapshot.docs.map(_mapAudit),
      ...alertsSnapshot.docs.map(_mapAlert),
    ];

    movements.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return movements;
  }

  StockMovement _mapReception(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return StockMovement(
      id: doc.id,
      type: 'reception',
      title: 'Recepción de mercadería',
      productName: data['productName'] ?? 'Producto sin nombre',
      barcode: data['barcode'] ?? '',
      userEmail: data['receivedByEmail'] ?? 'Sin usuario',
      quantity: data['totalUnits'],
      previousStock: data['previousStock'],
      newStock: data['newStock'],
      expectedStock: null,
      realStock: null,
      difference: null,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  StockMovement _mapAudit(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return StockMovement(
      id: doc.id,
      type: 'audit',
      title: 'Auditoría de stock',
      productName: data['productName'] ?? 'Producto sin nombre',
      barcode: data['barcode'] ?? '',
      userEmail: data['auditedByEmail'] ?? 'Sin usuario',
      quantity: null,
      previousStock: null,
      newStock: null,
      expectedStock: data['expectedStock'],
      realStock: data['realStock'],
      difference: data['difference'],
      createdAt: _parseDate(data['createdAt']),
    );
  }

  StockMovement _mapAlert(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return StockMovement(
      id: doc.id,
      type: 'alert',
      title: data['title'] ?? 'Alerta',
      productName: data['productName'] ?? 'Sin producto',
      barcode: data['barcode'] ?? '',
      userEmail: 'Sistema SIO',
      quantity: null,
      previousStock: null,
      newStock: null,
      expectedStock: null,
      realStock: null,
      difference: data['difference'],
      createdAt: _parseDate(data['createdAt']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}