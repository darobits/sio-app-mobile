import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reception.dart';

class ReceptionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Reception>> getReceptions() async {
    final snapshot = await _db
        .collection('receptions')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Reception.fromMap(
        id: doc.id,
        map: doc.data(),
      );
    }).toList();
  }
}