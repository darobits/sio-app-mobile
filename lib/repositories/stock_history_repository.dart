import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/stock_movement.dart';

class StockHistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<StockMovement>> getMovements() async {
    final receptionsSnapshot = await _db
        .collection('receptions')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final auditsSnapshot = await _db
        .collection('audits')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final alertsSnapshot = await _db
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final movements = <StockMovement>[];

    for (final doc in receptionsSnapshot.docs) {
      final data = doc.data();
      final timestamp = data['createdAt'];

      movements.add(
        StockMovement(
          id: doc.id,
          type: 'reception',
          title: 'Recepción de mercadería',
          productName: data['productName'] ?? 'Sin producto',
          barcode: data['barcode'] ?? '',
          userEmail: data['receivedByEmail'] ?? 'Sin usuario',
          quantity: _asNullableInt(data['totalUnits']),
          previousStock: _asNullableInt(data['previousStock']),
          newStock: _asNullableInt(data['newStock']),
          expectedStock: null,
          realStock: null,
          difference: null,
          createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
        ),
      );
    }

    for (final doc in auditsSnapshot.docs) {
      final data = doc.data();
      final timestamp = data['createdAt'];

      movements.add(
        StockMovement(
          id: doc.id,
          type: 'audit',
          title: 'Auditoría de stock',
          productName: data['productName'] ?? 'Sin producto',
          barcode: data['barcode'] ?? '',
          userEmail: data['auditedByEmail'] ?? 'Sin usuario',
          quantity: null,
          previousStock: null,
          newStock: null,
          expectedStock: _asNullableInt(data['expectedStock']),
          realStock: _asNullableInt(data['realStock']),
          difference: _asNullableInt(data['difference']),
          createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
        ),
      );
    }

    for (final doc in alertsSnapshot.docs) {
      final data = doc.data();
      final timestamp = data['createdAt'];

      movements.add(
        StockMovement(
          id: doc.id,
          type: 'alert',
          title: data['title'] ?? 'Alerta',
          productName: data['productName'] ?? 'Sin producto',
          barcode: data['barcode'] ?? '',
          userEmail: 'Sistema',
          quantity: null,
          previousStock: null,
          newStock: null,
          expectedStock: null,
          realStock: null,
          difference: _asNullableInt(data['difference']),
          createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
        ),
      );
    }

    movements.sort((a, b) {
      final dateA = a.createdAt ?? DateTime(1900);
      final dateB = b.createdAt ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });

    return movements;
  }

  int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}