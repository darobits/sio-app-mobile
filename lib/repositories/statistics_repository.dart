import 'dart:math';

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
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from),
        )
        .where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(to),
        )
        .orderBy('createdAt')
        .get();

    final auditsSnapshot = await _db
        .collection('audits')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from),
        )
        .where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(to),
        )
        .orderBy('createdAt')
        .get();

    int totalStock = 0;
    int lowStockProducts = 0;

    for (final doc in productsSnapshot.docs) {
      final data = doc.data();

      final stock = _asInt(data['currentStock']);

      totalStock += stock;

      if (stock <= 10) {
        lowStockProducts++;
      }
    }

    int totalReceivedUnits = 0;

    final receptionsByUser = <String, int>{};
    final receivedUnitsByProduct = <String, int>{};
    final receptionsByDay = <String, int>{};

    final rangeDays = max(1, to.difference(from).inDays);
    final groupByMonth = rangeDays > 60;

    for (final doc in receptionsSnapshot.docs) {
      final data = doc.data();

      final totalUnits = _asInt(data['totalUnits']);

      final userName = _asString(
        data['receivedByName'],
        fallback: _asString(
          data['receivedByEmail'],
          fallback: 'Sin usuario',
        ),
      );

      final productName = _asString(
        data['productName'],
        fallback: 'Sin producto',
      );

      final createdAt = data['createdAt'];

      totalReceivedUnits += totalUnits;

      receptionsByUser[userName] = (receptionsByUser[userName] ?? 0) + 1;

      receivedUnitsByProduct[productName] =
          (receivedUnitsByProduct[productName] ?? 0) + totalUnits;

      if (createdAt is Timestamp) {
        final date = createdAt.toDate();
        final key = groupByMonth ? _monthKey(date) : _dayKey(date);

        receptionsByDay[key] = (receptionsByDay[key] ?? 0) + 1;
      }
    }

    int auditsWithDifference = 0;

    final auditsDifferenceByProduct = <String, int>{};

    for (final doc in auditsSnapshot.docs) {
      final data = doc.data();

      final difference = _asInt(data['difference']);

      final productName = _asString(
        data['productName'],
        fallback: 'Sin producto',
      );

      if (difference != 0) {
        auditsWithDifference++;

        auditsDifferenceByProduct[productName] =
            (auditsDifferenceByProduct[productName] ?? 0) + difference.abs();
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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  String _asString(
    dynamic value, {
    required String fallback,
  }) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }

  String _dayKey(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month';
  }

  String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$month/$year';
  }
}