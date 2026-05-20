import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/operational_stats.dart';

class StatisticsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<OperationalStats> getStats({
    required DateTime from,
    required DateTime to,
  }) async {
    final productsSnapshot = await _db.collection('products').get();

    final receptionsSnapshot = await _db
        .collection('receptions')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    final auditsSnapshot = await _db
        .collection('audits')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    int totalStock = 0;
    int lowStockProducts = 0;

    for (final doc in productsSnapshot.docs) {
      final data = doc.data();
      final stock = data['currentStock'];

      if (stock is int) {
        totalStock += stock;

        if (stock <= 10) {
          lowStockProducts++;
        }
      }
    }

    int totalReceivedUnits = 0;
    final receptionsByUser = <String, int>{};
    final receivedUnitsByProduct = <String, int>{};
    final receptionsByDay = <String, int>{};

    for (final doc in receptionsSnapshot.docs) {
      final data = doc.data();

      final totalUnits = data['totalUnits'];
      final userEmail = data['receivedByEmail'];
      final productName = data['productName'];
      final createdAt = data['createdAt'];

      if (totalUnits is int) {
        totalReceivedUnits += totalUnits;
      }

      if (userEmail is String && userEmail.trim().isNotEmpty) {
        receptionsByUser[userEmail] = (receptionsByUser[userEmail] ?? 0) + 1;
      }

      if (productName is String && productName.trim().isNotEmpty) {
        receivedUnitsByProduct[productName] =
            (receivedUnitsByProduct[productName] ?? 0) +
                (totalUnits is int ? totalUnits : 0);
      }

      if (createdAt is Timestamp) {
        final date = createdAt.toDate();
        final key =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

        receptionsByDay[key] = (receptionsByDay[key] ?? 0) + 1;
      }
    }

    int auditsWithDifference = 0;
    final auditsDifferenceByProduct = <String, int>{};

    for (final doc in auditsSnapshot.docs) {
      final data = doc.data();

      final difference = data['difference'];
      final productName = data['productName'];

      if (difference is int && difference != 0) {
        auditsWithDifference++;

        if (productName is String && productName.trim().isNotEmpty) {
          auditsDifferenceByProduct[productName] =
              (auditsDifferenceByProduct[productName] ?? 0) + 1;
        }
      }
    }

    return OperationalStats(
      totalProducts: productsSnapshot.docs.length,
      totalStock: totalStock,
      totalReceptions: receptionsSnapshot.docs.length,
      totalReceivedUnits: totalReceivedUnits,
      totalAudits: auditsSnapshot.docs.length,
      auditsWithDifference: auditsWithDifference,
      lowStockProducts: lowStockProducts,
      receptionsByUser: receptionsByUser,
      receivedUnitsByProduct: receivedUnitsByProduct,
      receptionsByDay: receptionsByDay,
      auditsDifferenceByProduct: auditsDifferenceByProduct,
    );
  }
}