import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sio_alert.dart';

class AlertRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<SioAlert>> getAlerts() async {
    final snapshot = await _db
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return SioAlert.fromMap(
        id: doc.id,
        map: doc.data(),
      );
    }).toList();
  }

  Future<void> markAsRead(String alertId) async {
    await _db.collection('alerts').doc(alertId).update({
      'read': true,
    });
  }

  Future<void> deleteAlert(String alertId) async {
    await _db.collection('alerts').doc(alertId).delete();
  }
}