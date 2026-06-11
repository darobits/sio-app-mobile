import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_service.dart';

class AlertService {
  AlertService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> createAlert({
    required String type,
    required String title,
    required String message,
    String? barcode,
    String? productName,
    int? difference,
    bool sendNotification = true,
  }) async {
    await _db.collection('alerts').add({
      'type': type,
      'title': title,
      'message': message,
      'barcode': barcode,
      'productName': productName,
      'difference': difference,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (sendNotification) {
      await NotificationService.showNotification(
        title: title,
        body: message,
      );
    }
  }

  static Future<void> checkLowStock({
    required String barcode,
    required String productName,
    required int currentStock,
    int minimumStock = 10,
    bool sendNotification = true,
  }) async {
    if (currentStock > minimumStock) return;

    await createAlert(
      type: 'low_stock',
      title: 'Stock bajo',
      message:
          '$productName tiene stock bajo. Quedan $currentStock unidades disponibles.',
      barcode: barcode,
      productName: productName,
      sendNotification: sendNotification,
    );
  }

  static Future<void> checkAuditDifference({
    required String barcode,
    required String productName,
    required int expectedStock,
    required int realStock,
    bool sendNotification = true,
  }) async {
    final difference = realStock - expectedStock;

    if (difference == 0) return;

    await createAlert(
      type: 'stock_difference',
      title: 'Diferencia de stock detectada',
      message:
          '$productName: esperado $expectedStock, real $realStock. Diferencia: $difference unidades.',
      barcode: barcode,
      productName: productName,
      difference: difference,
      sendNotification: sendNotification,
    );
  }

  static Future<void> checkAbnormalLoad({
    required String barcode,
    required String productName,
    required int receivedUnits,
    int abnormalThreshold = 500,
    bool sendNotification = true,
  }) async {
    if (receivedUnits < abnormalThreshold) return;

    await createAlert(
      type: 'abnormal_load',
      title: 'Carga anormal detectada',
      message:
          '$productName recibió una carga alta de $receivedUnits unidades.',
      barcode: barcode,
      productName: productName,
      sendNotification: sendNotification,
    );
  }
}